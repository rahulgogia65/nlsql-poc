defmodule NlsqlWeb.TucanDemoLive do
  use NlsqlWeb, :live_view
  alias NlsqlWeb.Live.Components.TucanChartComponent

  @impl true
  def mount(_params, _session, socket) do
    # Sample data for charts
    sales_data = [
      %{label: "Jan", value: 12500},
      %{label: "Feb", value: 17800},
      %{label: "Mar", value: 14200},
      %{label: "Apr", value: 19500},
      %{label: "May", value: 22300},
      %{label: "Jun", value: 25100}
    ]

    product_data = [
      %{label: "Product A", value: 32},
      %{label: "Product B", value: 45},
      %{label: "Product C", value: 27},
      %{label: "Product D", value: 18}
    ]

    socket =
      socket
      |> assign(:page_title, "Tucan Chart Demo")
      |> assign(:sales_data, sales_data)
      |> assign(:product_data, product_data)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-3xl font-bold mb-8">Tucan Chart Visualization Demo</h1>

      <div class="grid md:grid-cols-2 gap-8">
        <div>
          <.live_component
            module={TucanChartComponent}
            id="sales-chart"
            title="Monthly Sales"
            data={@sales_data}
            chart_type="bar"
          />
        </div>

        <div>
          <.live_component
            module={TucanChartComponent}
            id="product-chart"
            title="Product Distribution"
            data={@product_data}
            chart_type="pie"
          />
        </div>
      </div>

      <div class="mt-8 bg-gray-100 p-6 rounded">
        <h2 class="text-xl font-semibold mb-4">How It Works</h2>
        <p class="mb-2">
          This demo uses the Tucan Elixir charting library to render SVG-based charts.
        </p>
        <p class="mb-2">
          The chart configuration is generated using <code>Nlsql.Visualizer.ChartGenerator</code>,
          which adapts your data to the format Tucan expects.
        </p>
        <p>
          You can switch between different chart types using the buttons above each chart.
        </p>
      </div>
    </div>
    """
  end
end
