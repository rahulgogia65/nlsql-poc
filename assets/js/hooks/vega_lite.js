import vegaEmbed from "vega-embed";

/**
 * A hook used to render graphics according to the given
 * Vega-Lite specification.
 *
 * The hook expects a `vega_lite:<id>:init` event with `{ spec }` payload,
 * where `spec` is the graphic definition as an object.
 *
 * Configuration:
 *
 *   * `data-id` - plot id
 */
const VegaLite = {
  mounted() {
    this.id = this.el.getAttribute("data-id");
    this.viewPromise = null;

    const container = document.createElement("div");
    this.el.appendChild(container);

    this.handleEvent(`vega_lite:${this.id}:init`, ({ spec }) => {
      this.viewPromise = vegaEmbed(container, spec, {
        actions: true,
        theme: "default"
      })
        .then((result) => result.view)
        .catch((error) => {
          console.error(
            `Failed to render the given Vega-Lite specification, got the following error:\n\n    ${error.message}\n\nMake sure to check for typos.`
          );
        });
    });
  },

  destroyed() {
    if (this.viewPromise) {
      this.viewPromise.then((view) => view.finalize());
    }
  },

  updated() {
    // Handle updates to the specification
    if (this.viewPromise) {
      this.viewPromise.then((view) => {
        // Clean up the old view
        view.finalize();
        this.viewPromise = null;
      });
    }
  }
};

export default VegaLite; 