// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

let Hooks = {}

// sortable.js
import Sortable from "sortablejs";
Hooks.Sortable = {
  mounted() {
    let sorter = new Sortable(this.el, {
      animation: 150,
      delay: 0,
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      forceFallback: true,
      onStart: function (evt) {
        window.mouseDownElement = null;
      },
      onEnd: e => {
        let params = {old: e.oldIndex, new: e.newIndex, ...e.item.dataset}
        this.pushEventTo(this.el, "reposition", params)
      }
    })
  }
}

function getCancellableClickTarget(elem) {
  if (!elem) return null;
  if (elem.attributes.hasOwnProperty("phx-cancellable-click")) return elem;
  return getCancellableClickTarget(elem.parentElement);
}
function inLabelOrButton(elem) {
  if (!elem) return false;
  if (elem.tagName == "LABEL" || elem.tagName == "BUTTON") return true;
  return inLabelOrButton(elem.parentElement);
}

window.mouseDownElement = null;
Hooks.ClickListener = {
  mounted() {
    this.el.addEventListener('mousedown', e => {
      var target = getCancellableClickTarget(e.target);
      if (target !== null) {
        window.mouseDownElement = target;
      }
    });
    this.el.addEventListener('mouseup', e => {
      var target = getCancellableClickTarget(e.target);
      if (target !== null) {
        if (window.mouseDownElement == target) {
          var params = {};
          for (let attr of target.attributes) {
            if (attr.name.startsWith("phx-value-")) {
              var key = attr.name.substring(10);
              params[key] = attr.value;
            }
          }
          if (target.attributes.hasOwnProperty("phx-target")) {
            this.pushEventTo(target.getAttribute("phx-target"), target.getAttribute("phx-cancellable-click"), params);
          } else {
            this.pushEvent(target.getAttribute("phx-cancellable-click"), params);
          }
        }
        window.mouseDownElement = null;
      }
    });
    this.el.addEventListener('dblclick', e => {
      e.preventDefault();
      if (!inLabelOrButton(e.target) && !e.target.attributes.hasOwnProperty("phx-click") && !e.target.attributes.hasOwnProperty("phx-cancellable-click")) {
        this.pushEvent("double_clicked");
      }
    });
    this.el.addEventListener('contextmenu', e => {
      e.preventDefault();
      if (!inLabelOrButton(e.target) && !e.target.attributes.hasOwnProperty("phx-click") && !e.target.attributes.hasOwnProperty("phx-cancellable-click")) {
        this.pushEvent("right_clicked");
      }
    });
  }
}

import Delta from "quill-delta";
import { v4 as uuidv4 } from "uuid";
window.client_doc = new Delta().insert("");
window.client_deltas = []; // queue
window.server_doc = new Delta().insert("");
window.server_version = 0;
Hooks.CollaborativeTextarea = {
  mounted() {
    this.el.value = "";
    var debounced = (fun) => (...args) => {
      window.clearTimeout(window.delta_debounce);
      window.delta_debounce = window.setTimeout(() => fun.apply(this, args), 50);
    }
    // var d1 = new Delta().insert("");
    // var d2 = new Delta().insert("a");
    // var d3 = new Delta().insert("ab");
    // var d4 = new Delta().insert("abc");
    // var ds = [new Delta().insert("a"), new Delta().insert("b"), new Delta().insert("c")]
    // var di = [
    //   new Delta().insert("a").invert(d1),
    //   new Delta().insert("b").invert(d2),
    //   new Delta().insert("c").invert(d3),
    // ]
    // var d = new Delta().delete(3);
    // var dd = di.reduceRight((acc, inv) => inv.transform(acc, true), d);

    // console.log("Asdf", di);
    // console.log("Asdf", dd);

    function update() {
      var new_client_doc = new Delta().insert(this.el.value)
      // console.log(JSON.stringify(window.client_doc.ops), JSON.stringify(new_client_doc.ops));
      var client_delta = window.client_doc.diff(new_client_doc);
      var inverse_delta = client_delta.invert(window.client_doc);
      var old_client_doc = window.client_doc; // debug only
      window.client_doc = new_client_doc;
      if (client_delta.ops.length > 0) {
        // console.log(
        //   `
        //   at version ${window.server_version}
        //   Our current textbox looks like: ${this.el.value}
        //   According to the client, it should be: ${get_contents(old_client_doc)}
        //   According to the server, it should be: ${get_contents(window.server_doc)}
        //   So we calculate the delta from our client doc: ${JSON.stringify(client_delta.ops)}
        //   which we send to the server.
        //   `);
        var uuid = uuidv4();
        window.client_deltas.push({"uuid": uuid, "delta": client_delta, "inverse": inverse_delta});
        var applied_uuids = window.client_deltas.map(delta => delta["uuid"]);
        this.pushEventTo(this.el.getAttribute("phx-target"), "push_delta", {"version": window.server_version, "uuid": uuid, "delta": client_delta["ops"], "applied_uuids": applied_uuids});
      } else {
        // console.log(
        //   `
        //   at version ${window.server_version}
        //   Our current textbox looks like: ${this.el.value}
        //   According to the client, it should be: ${get_contents(window.client_doc)}
        //   According to the server, it should be: ${get_contents(window.server_doc)}
        //   No change, so not sending an update
        //   `);
      }
    }
    this.el.addEventListener('focus', debounced(update).bind(this));
    this.el.addEventListener('blur', debounced(update).bind(this));
    this.el.addEventListener('keyup', (e) => {
      // console.log("key pressed:", e.key, this.el.value);
      debounced(update).bind(this)();
    });

    function get_contents(delta) {
      if (delta.ops.length > 0) return delta.ops[0]["insert"];
      else return "";
    }

    function write({from_version, version, uuids, deltas}) {
      var same_version = window.server_version == from_version;
      var server_deltas = deltas.map(delta => new Delta(delta));
      // console.log(`Received update ${from_version}=>${version}: ${JSON.stringify(server_deltas)}`);
      if (same_version) { // TODO just drop initial deltas if we're a newer version
        update.bind(this)(); // add current delta, if there is one, to window.client_deltas
        // drop all client deltas that are accounted for by the server delta
        // only do this after adding the current delta
        window.client_deltas = window.client_deltas.filter(change => !uuids.includes(change["uuid"]));
        // only after adding current delta do we update the server doc
        var server_delta = server_deltas.reduce((acc, delta) => acc.compose(delta), new Delta());
        window.server_version = version;
        window.server_doc = window.server_doc.compose(server_delta);
        if (window.client_deltas.length > 0) {
          // roll any remaining client deltas into one delta
          // and transform it against the server delta (server goes first)
          var client_delta = window.client_deltas.map(change => change["delta"]).reduce((acc, delta) => acc.compose(delta));
          var server_delta_inv = server_delta.invert(window.server_doc);
          var composed_client_delta = server_delta_inv.compose(client_delta);
          var transformed_client_delta = server_delta.compose(composed_client_delta);
          // console.log(
          //   `
          //   updating ${from_version}=>${version}
          //   server diffs: ${JSON.stringify(server_deltas.map(delta => delta.ops))}
          //   total server diff: ${JSON.stringify(server_delta.ops)}
          //   Our current textbox looks like: ${this.el.value}
          //   According to the client, it should be: ${get_contents(window.client_doc)}
          //   According to the server, it should be: ${get_contents(window.server_doc)}
          //   Our pending client deltas sum up to be: ${JSON.stringify(client_delta.ops)}
          //   But first we precompose with the inverse server delta: ${JSON.stringify(server_delta_inv.ops)}
          //   to get: ${JSON.stringify(composed_client_delta.ops)}
          //   Then we transform with the server delta: ${JSON.stringify(server_delta.ops)}
          //   to get: ${JSON.stringify(transformed_client_delta.ops)}
          //   when applied to the updated version of the server document, we get: ${get_contents(window.client_doc)}
          //   `);

          // apply client delta to the updated server document to get the updated client document
          window.client_doc = window.server_doc.compose(transformed_client_delta);
        } else {
          window.client_doc = window.server_doc;
          // console.log(
          //   `
          //   updating ${from_version}=>${version}
          //   server diff: ${JSON.stringify(server_delta.ops)}
          //   Our current textbox looks like: ${this.el.value}
          //   According to the client, it should be: ${get_contents(window.client_doc)}
          //   According to the server, it should be: ${get_contents(window.server_doc)}
          //   We have no pending client deltas, so our client doc is the same
          //   `);
        }
        // set textarea to client doc contents
        this.el.value = get_contents(window.client_doc);
      } else {
        console.log(`Rejecting update ${from_version}=>${version} since our version is ${window.server_version}`);
      }
    }
    this.handleEvent("apply-delta", debounced(write).bind(this));
  }
}

window.addEventListener("phx:play-sound", ev => {
  var audio = new Audio(ev.detail.path);
  audio.play();
});
window.addEventListener("phx:copy-log", ev => {
  navigator.clipboard.writeText(ev.detail.log);
});

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  // longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket

