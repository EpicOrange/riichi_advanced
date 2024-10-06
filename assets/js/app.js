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
window.delta_version = 0;
window.delta = new Delta().insert("");
Hooks.CollaborativeTextarea = {
  mounted() {
    this.handleEvent("apply-delta", ({from_version, version, delta}) => {
      if (window.delta_version == from_version) {
        window.delta_version = version;
        window.delta = window.delta.compose(new Delta(delta));
        if (window.delta.ops.length > 0) {
          this.el.value = window.delta.ops[0]["insert"];
        } else {
          this.el.value = "";
        }
      }
    });
    function update(el) {
      var client_delta = window.delta.diff(new Delta().insert(this.el.value));
      this.pushEventTo(this.el.getAttribute("phx-target"), "push_delta", {"version": window.delta_version, "delta": client_delta["ops"]});
    }
    this.el.addEventListener('focus', update.bind(this));
    this.el.addEventListener('blur', update.bind(this));
    this.el.addEventListener('keyup', update.bind(this));
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

