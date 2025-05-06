defmodule NlsqlWeb.VegaLiteDemoLive do
  use NlsqlWeb, :live_view
  alias NlsqlWeb.Components.VegaLiteComponent
  alias NlsqlWeb.Helpers.VegaLiteSpecs

  @impl true
  def mount(_params, _session, socket) do
    # Sample data for bar chart
    bar_data = [
      %{"category" => "A", "value" => 28},
      %{"category" => "B", "value" => 55},
      %{"category" => "C", "value" => 43},
      %{"category" => "D", "value" => 91},
      %{"category" => "E", "value" => 81},
      %{"category" => "F", "value" => 53},
      %{"category" => "G", "value" => 19},
      %{"category" => "H", "value" => 87}
    ]

    # Sample data for line chart (time series)
    line_data = [
      %{"date" => "2023-01", "value" => 4},
      %{"date" => "2023-02", "value" => 6},
      %{"date" => "2023-03", "value" => 10},
      %{"date" => "2023-04", "value" => 15},
      %{"date" => "2023-05", "value" => 12},
      %{"date" => "2023-06", "value" => 18},
      %{"date" => "2023-07", "value" => 22},
      %{"date" => "2023-08", "value" => 25},
      %{"date" => "2023-09", "value" => 21},
      %{"date" => "2023-10", "value" => 17},
      %{"date" => "2023-11", "value" => 13},
      %{"date" => "2023-12", "value" => 9}
    ]

    # Sample data for pie chart
    pie_data = [
      %{"category" => "Category 1", "value" => 30},
      %{"category" => "Category 2", "value" => 45},
      %{"category" => "Category 3", "value" => 25}
    ]

    # Create chart specifications
    bar_spec = VegaLiteSpecs.bar_chart_spec(bar_data,
      title: "Bar Chart Example",
      colors: ["#4C72B0", "#55A868", "#C44E52", "#8172B3", "#937860", "#DA8BC3", "#8C8C8C", "#CCB974"]
    )

    line_spec = VegaLiteSpecs.line_chart_spec(line_data,
      title: "Line Chart Example",
      x_field: "date",
      y_field: "value",
      colors: ["#4C72B0"]
    )

    pie_spec = VegaLiteSpecs.pie_chart_spec(pie_data,
      title: "Pie Chart Example",
      colors: ["#4C72B0", "#55A868", "#C44E52"]
    )

    socket =
      socket
      |> assign(:page_title, "Vega-Lite Demo")
      |> assign(:bar_spec, bar_spec)
      |> assign(:line_spec, line_spec)
      |> assign(:pie_spec, pie_spec)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-2xl font-bold mb-6">Vega-Lite Chart Demos</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <div class="bg-white p-6 rounded-lg shadow-md">
          <h2 class="text-xl font-semibold mb-4">Bar Chart</h2>
          <.live_component
            module={VegaLiteComponent}
            id="bar-chart"
            spec={@bar_spec}
            class="w-full h-64"
          />
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md">
          <h2 class="text-xl font-semibold mb-4">Line Chart</h2>
          <.live_component
            module={VegaLiteComponent}
            id="line-chart"
            spec={@line_spec}
            class="w-full h-64"
          />
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-md">
        <h2 class="text-xl font-semibold mb-4">Pie Chart</h2>
        <.live_component
          module={VegaLiteComponent}
          id="pie-chart"
          spec={@pie_spec}
          class="w-full h-64"
        />
      </div>
    </div>
    """
  end
end
