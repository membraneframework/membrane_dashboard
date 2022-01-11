import "phoenix_html";

import Alpine from "alpinejs";
import ChartsHook from "./hooks/ChartsHook";
import DagreHook from "./hooks/DagreHook";
import topbar from "topbar";
import { LiveSocket } from "phoenix_live_view";
import { Socket } from "phoenix";
import LogsHook from "./hooks/LogsHook";

declare global {
  interface Window {
    liveSocket: LiveSocket;
    Alpine: object;
  }
}

const Hooks = {
  Dagre: DagreHook,
  Charts: ChartsHook,
  Logs: LogsHook,
};

const csrfToken = document
  .querySelector("meta[name='csrf-token']")!
  .getAttribute("content");

// Initialize Alpine.js
window.Alpine = Alpine;
Alpine.start();

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      // @ts-ignore
      if (from._x_dataStack) {
        // @ts-ignore
        window.Alpine.clone(from, to);
        return true;
      }
      return false;
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });

window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
