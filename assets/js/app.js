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

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Include Chart.js library
import Chart from 'chart.js/auto';

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Define hooks for LiveView
let Hooks = {};

// Chart hook for displaying visualizations
Hooks.ChartHook = {
  mounted() {
    this.initChart();
    
    // Set up listener for when chart config changes
    this.handleEvent("update-chart", ({ config }) => {
      this.updateChart(config);
    });
  },
  
  initChart() {
    const canvas = this.el;
    const config = JSON.parse(canvas.dataset.chartConfig);
    
    // Destroy existing chart if it exists
    if (this.chart) {
      this.chart.destroy();
    }
    
    // Create the new chart
    this.chart = new Chart(canvas, config);
  },
  
  updateChart(config) {
    // Destroy existing chart
    if (this.chart) {
      this.chart.destroy();
    }
    
    // Create new chart with updated config
    this.chart = new Chart(this.el, config);
  },
  
  destroyed() {
    // Clean up chart when element is removed
    if (this.chart) {
      this.chart.destroy();
    }
  }
};

// Export hooks
export const liveSocketOptions = {
  hooks: Hooks
};

