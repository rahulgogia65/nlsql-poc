defmodule NlsqlWeb.Live.Components.TucanChartComponent do
  use Phoenix.LiveComponent
  alias Nlsql.Visualizer.ChartGenerator
  alias NlsqlWeb.Components.TucanComponent
  import TucanComponent

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_chart()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tucan-chart-component">
      <h3 class="text-lg font-semibold mb-4"><%= @title %></h3>

      <div class="chart-controls mb-4">
        <div class="inline-flex">
          <div class="px-4 py-2 text-sm font-medium bg-blue-500 text-white border border-blue-600 rounded-md">
            <%= String.capitalize(@chart_type) %> Chart
          </div>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-md">
        <.tucan_visualization
          id={"chart-#{@id}"}
          data={@tucan_config}
          class="w-full h-64"
          phx-target={@myself}
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("change-chart-type", %{"type" => type}, socket) do
    socket =
      socket
      |> assign(:chart_type, type)
      |> assign_chart()

    {:noreply, socket}
  end

  @impl true
  def handle_event("tucan-visibility-change", %{"id" => _id, "visible" => true}, socket) do
    # Chart became visible, regenerate the chart to ensure it's properly displayed
    socket = assign_chart(socket)
    {:noreply, socket}
  end

  # Helper to generate the Tucan chart config based on chart type
  defp assign_chart(socket) do
    chart_data = format_data_for_chart(socket.assigns.data, socket.assigns.chart_type)

    tucan_config = ChartGenerator.generate_tucan_chart(chart_data, socket.assigns.chart_type) |> dbg()

    assign(socket, :tucan_config, tucan_config)
  end

  # Format the raw data for the chart generator based on chart type
  defp format_data_for_chart(raw_data, chart_type) do
    # Handle both direct chart.js format or our existing data format
    case raw_data do
      %{"labels" => labels, "datasets" => [dataset | _]} ->
        # Direct Chart.js format from @active_chart.config.data with string keys
        format_by_chart_type(labels, dataset, chart_type)

      %{labels: labels, datasets: [dataset | _]} ->
        # Chart.js format with atom keys
        format_by_chart_type(labels, dataset, chart_type)

      _ when is_list(raw_data) ->
        # Our existing format when using as a standalone component
        formatted_data = Enum.map(raw_data, fn item ->
          %{"x" => Map.get(item, :label), "y" => Map.get(item, :value)}
        end)

        format_list_by_chart_type(formatted_data, chart_type)

      _ ->
        # Default empty format
        %{
          data: [],
          labels: %{
            x: "Category",
            y: "Value"
          }
        }
    end
  end

  # Format data based on chart type for chart.js format
  defp format_by_chart_type(labels, dataset, chart_type) do
    label = if is_map(dataset) && Map.has_key?(dataset, "label"), do: dataset["label"], else: Map.get(dataset, :label, "Category")
    data = if is_map(dataset) && Map.has_key?(dataset, "data"), do: dataset["data"], else: Map.get(dataset, :data, [])

    case chart_type do
      "pie" ->
        # Pie charts need data in a different format
        formatted_data = Enum.zip(labels, data)
        |> Enum.map(fn {label, value} ->
          %{"x" => label, "y" => value}
        end)

        %{
          data: formatted_data,
          labels: %{
            x: "Category",
            y: "Value"
          }
        }

      "line" ->
        # Line charts might need ordered data points
        formatted_data = Enum.zip(labels, data)
        |> Enum.with_index()
        |> Enum.map(fn {{label, value}, index} ->
          %{"x" => index, "y" => value, "label" => label}
        end)

        %{
          data: formatted_data,
          labels: %{
            x: "Index",
            y: label || "Value"
          }
        }

      _ ->
        # Default format for bar and other charts
        formatted_data = Enum.zip(labels, data)
        |> Enum.map(fn {label, value} ->
          %{"x" => label, "y" => value}
        end)

        %{
          data: formatted_data,
          labels: %{
            x: label || "Category",
            y: "Value"
          }
        }
    end
  end

  # Format list data based on chart type
  defp format_list_by_chart_type(formatted_data, chart_type) do
    case chart_type do
      "pie" ->
        # Reformat for pie charts
        pie_data = Enum.map(formatted_data, fn item ->
          %{"x" => Map.get(item, "x"), "y" => Map.get(item, "y")}
        end)

        %{
          data: pie_data,
          labels: %{
            name: "Category",
            value: "Value"
          }
        }

      "line" ->
        # Reformat for line charts with explicit indices
        line_data = formatted_data
        |> Enum.with_index()
        |> Enum.map(fn {item, index} ->
          %{"x" => index, "y" => Map.get(item, "y"), "label" => Map.get(item, "x")}
        end)

        %{
          data: line_data,
          labels: %{
            x: "Index",
            y: "Value"
          }
        }

      _ ->
        # Default format for bar and other charts
        %{
          data: formatted_data,
          labels: %{
            x: "Category",
            y: "Value"
          }
        }
    end
  end
end
