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
function getHoverTarget(elem) {
  if (!elem) return null;
  if (elem.attributes.hasOwnProperty("phx-hover")) return elem;
  return getHoverTarget(elem.parentElement);
}
function inLabelOrButton(elem) {
  if (!elem) return false;
  if (elem.tagName == "LABEL" || elem.tagName == "BUTTON") return true;
  return inLabelOrButton(elem.parentElement);
}

window.mouseDownElement = null;
window.hoverElement = null;
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
    this.el.addEventListener('mousemove', e => {
      var target = getHoverTarget(e.target);
      if (target !== null) {
        if (window.hoverElement !== target) {
          var params = {};
          for (let attr of target.attributes) {
            if (attr.name.startsWith("phx-value-")) {
              var key = attr.name.substring(10);
              params[key] = attr.value;
            }
          }
          if (target.attributes.hasOwnProperty("phx-target")) {
            this.pushEventTo(target.getAttribute("phx-target"), target.getAttribute("phx-hover"), params);
          } else {
            this.pushEvent(target.getAttribute("phx-hover"), params);
          }
        }
        window.hoverElement = target;
      } else {
        if (window.hoverElement !== null && window.hoverElement.attributes.hasOwnProperty("phx-hover-off")) {
          target = window.hoverElement;
          if (target.attributes.hasOwnProperty("phx-target")) {
            this.pushEventTo(target.getAttribute("phx-target"), target.getAttribute("phx-hover-off"), params);
          } else {
            this.pushEvent(target.getAttribute("phx-hover-off"), params);
          }
        }
        window.hoverElement = null;
      }
    });
  }
}

import Delta from "quill-delta";
import { v4 as uuidv4 } from "uuid";
window.client_doc = new Delta().insert("");
window.client_deltas = [];
window.client_delta_uuids = [];
window.server_doc = new Delta().insert("");
window.server_version = -1;
Hooks.CollaborativeTextarea = {
  mounted() {
    this.el.value = "";
    var debounced = (fun) => (...args) => {
      window.clearTimeout(window.delta_debounce);
      window.delta_debounce = window.setTimeout(() => fun.apply(this, args), 50);
    }
    function update(no_poll) {
      var new_client_doc = new Delta().insert(this.el.value)
      var client_delta = window.client_doc.diff(new_client_doc);
      window.client_doc = new_client_doc;
      var uuid = uuidv4();
      if (client_delta.ops.length > 0) {
        window.client_deltas.push(client_delta);
        window.client_delta_uuids.push(uuid);
        var params = {"version": window.server_version, "uuids": window.client_delta_uuids, "deltas": window.client_deltas.map(delta => delta["ops"])};
        this.pushEventTo(this.el.getAttribute("phx-target"), "push_delta", params);
      } else {
        if (!no_poll) this.pushEventTo(this.el.getAttribute("phx-target"), "poll_deltas", {"version": window.server_version});
      }
    }
    this.el.addEventListener('focus', () => debounced(update).bind(this)(false));
    this.el.addEventListener('blur', () => debounced(update).bind(this)(false));
    this.el.addEventListener('keyup', (e) => {
      // console.log("key pressed:", e.key, this.el.value);
      debounced(update).bind(this)(false);
    });

    function get_contents(delta) {
      if (delta.ops.length > 0) return delta.ops[0]["insert"] || "";
      else return "";
    }

    function write({from_version, version, uuids, deltas}) {
      var same_version = window.server_version == from_version;
      var server_deltas = deltas.map(delta => new Delta(delta));
      var server_delta = server_deltas.reduce((acc, delta) => acc.compose(delta), new Delta());
      // console.log(`Received update ${from_version}=>${version}: ${JSON.stringify(server_deltas)}`);
      // check if it's a full reload
      if (from_version < 0) {
        same_version = true;
        window.server_doc = new Delta().insert("");
        window.server_version = from_version;
      }
      if (same_version) { // TODO just drop initial deltas if we're a newer version
        update.bind(this)(true); // add current delta, if there is one, to window.client_deltas
        // take only client deltas that are not accounted for by the server delta
        var flattened_uuids = uuids.flat();
        var client_delta_uuids = window.client_delta_uuids.filter(uuid => !flattened_uuids.includes(uuid));
        var client_deltas = window.client_deltas.filter((delta, i) => !flattened_uuids.includes(window.client_delta_uuids[i]));
        var client_delta = client_deltas.reduce((acc, delta) => acc.compose(delta), new Delta());
        // store diff between client and server doc (for cursor calculation later)
        var undo = window.client_doc.diff(window.server_doc);
        var redo = undo.invert(window.client_doc);
        // only then do we update the server doc
        window.server_version = version;
        window.server_doc = window.server_doc.compose(server_delta);
        window.client_doc = window.server_doc.compose(client_delta);
        // calculate new cursor position
        var server_only_deltas = server_deltas.filter((delta, i) => uuids[i].every(uuid => !window.client_delta_uuids.includes(uuid)));
        var server_only_delta = server_only_deltas.reduce((acc, delta) => acc.compose(delta), new Delta());
        var new_cursor_position = undo.compose(server_only_delta).compose(redo).transformPosition(this.el.selectionEnd);
        // set textarea to client doc contents
        this.el.value = get_contents(window.client_doc);
        this.el.selectionEnd = new_cursor_position;
        // update client deltas to be all unaccounted-for client deltas
        window.client_deltas = client_deltas;
        window.client_delta_uuids = client_delta_uuids;
      } else {
        // console.log(`Rejecting update ${from_version}=>${version} since our version is ${window.server_version}`);
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

