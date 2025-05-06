/**
 * A hook used to render and manage Tucan SVG visualizations.
 *
 * The hook expects SVG content to be rendered within its element.
 * It handles updates and cleanup of the visualization.
 */
const TucanView = {
  mounted() {
    this.id = this.el.id;
    this.svgElement = this.el.querySelector('svg');
    
    if (this.svgElement) {
      // Store initial SVG content
      this.initialSvg = this.svgElement.outerHTML;
      
      // Add any interactive features or event listeners here
      this.setupInteractivity();

      // Add visibility change detection
      this.setupVisibilityDetection();
    }
  },

  updated() {
    // Handle updates to the SVG content
    const newSvg = this.el.querySelector('svg');
    if (newSvg && newSvg.outerHTML !== this.initialSvg) {
      this.initialSvg = newSvg.outerHTML;
      this.svgElement = newSvg;
      this.setupInteractivity();
    }
  },

  destroyed() {
    // Cleanup any event listeners or resources
    this.cleanupInteractivity();
    this.cleanupVisibilityDetection();
  },

  setupInteractivity() {
    // Add any interactive features to the SVG
    // For example, tooltips, zoom, pan, etc.
    if (this.svgElement) {
      // Example: Add click handler for data points
      const dataPoints = this.svgElement.querySelectorAll('.data-point');
      dataPoints.forEach(point => {
        point.addEventListener('click', (e) => {
          this.handleDataPointClick(e);
        });
      });
    }
  },

  cleanupInteractivity() {
    // Remove event listeners and cleanup resources
    if (this.svgElement) {
      const dataPoints = this.svgElement.querySelectorAll('.data-point');
      dataPoints.forEach(point => {
        point.removeEventListener('click', this.handleDataPointClick);
      });
    }
  },

  handleDataPointClick(event) {
    // Handle click events on data points
    const data = event.target.dataset;
    if (data) {
      // Push event to LiveView
      this.pushEvent('tucan-interaction', {
        type: 'data-point-click',
        data: data
      });
    }
  },

  setupVisibilityDetection() {
    // Monitor for tab visibility changes
    this.visibilityObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          // Element is now visible, refresh if needed
          this.onBecomeVisible();
        }
      });
    }, { threshold: 0.1 }); // Trigger when at least 10% is visible
    
    this.visibilityObserver.observe(this.el);

    // Also listen for custom LiveView navigation events
    window.addEventListener("phx:page-loading-stop", this.onPageReload.bind(this));
  },

  cleanupVisibilityDetection() {
    if (this.visibilityObserver) {
      this.visibilityObserver.disconnect();
    }
    window.removeEventListener("phx:page-loading-stop", this.onPageReload);
  },

  onBecomeVisible() {
    // The chart is now visible (e.g., tab switched to)
    // Request a refresh from the LiveView if needed
    this.pushEvent('tucan-visibility-change', {
      id: this.id,
      visible: true
    });
  },

  onPageReload() {
    // LiveView navigation has completed
    if (this.el && this.isVisible(this.el)) {
      // Wait a short time to let the DOM stabilize
      setTimeout(() => {
        const newSvg = this.el.querySelector('svg');
        if (newSvg && newSvg !== this.svgElement) {
          this.svgElement = newSvg;
          this.initialSvg = newSvg.outerHTML;
          this.setupInteractivity();
        }
      }, 50);
    }
  },

  isVisible(element) {
    const rect = element.getBoundingClientRect();
    return rect.top >= 0 &&
           rect.left >= 0 &&
           rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
           rect.right <= (window.innerWidth || document.documentElement.clientWidth);
  }
};

export default TucanView; 