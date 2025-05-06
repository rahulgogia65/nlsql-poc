defmodule NlsqlWeb.Components.TucanComponent do
  use Phoenix.Component
  import Phoenix.HTML
  use PhoenixHTMLHelpers

  @doc """
  Renders a Tucan visualization component.

  ## Examples
      <.tucan_visualization
        id="my-chart"
        data={@chart_data}
        options={@chart_options}
      />
  """
  attr :id, :string, required: true
  attr :data, :map, required: true
  attr :options, :map, default: %{}
  attr :class, :string, default: ""
  attr :phx_target, :any, default: nil, doc: "The phx-target for events (usually @myself)"

  def tucan_visualization(assigns) do
    # Check if data is already a Tucan config or needs to be processed
    tucan_config = assigns.data

    # Only process if tucan_config is valid
    assigns = if is_nil(tucan_config) do
      # Return a placeholder or error message when no valid chart can be created
      assign(assigns, :svg_content, "<svg width='100%' height='100%'><text x='50%' y='50%' text-anchor='middle' dominant-baseline='middle'>No data available for visualization</text></svg>")
    else
      tucan_config |> dbg()
      # Convert to SVG
      svg_content = Tucan.Export.to_svg(tucan_config) |> dbg(limit: :infinity, printable_limit: :infinity)

      assign(assigns, :svg_content, svg_content)
    end

    ~H"""
    <div
      id={@id}
      class={"tucan-visualization #{@class}"}
      phx-hook="TucanView"
      phx-update="ignore"
      phx-target={@phx_target}
    >
      <%= raw(@svg_content) %>
    </div>
    """
  end

  # Generate a Tucan chart based on chart type in options
  defp generate_tucan_chart(data, options) do
    chart_type = Map.get(options, :type, "bar")

    case chart_type do
      "bar" -> generate_bar_chart(data, options)
      "line" -> generate_line_chart(data, options)
      "pie" -> generate_pie_chart(data, options)
      _ -> generate_bar_chart(data, options) # Default to bar
    end
  end

  defp generate_bar_chart(data, _options) do
    # Ensure data is in the expected format
    tabular_data = case data do
      %{datasets: _} = chart_data ->
        # Extract first dataset if in chart.js format
        dataset = List.first(chart_data.datasets)
        Enum.zip(chart_data.labels, dataset.data)
        |> Enum.map(fn {label, value} -> %{"category" => label, "value" => value} end)
      _ -> data
    end

    # Calculate dimensions based on data size
    data_count = if is_list(tabular_data), do: length(tabular_data), else: 5
    # Adjust width for more data points
    width = max(400, min(800, 400 + data_count * 20))
    # Adjust height to give more space for labels when many data points
    height = max(300, min(600, 300 + data_count * 10))

    tabular_data
    |> Tucan.set_height(height)
    |> Tucan.set_width(width)
  end

  defp generate_line_chart(data, options) do
    title = Map.get(options, :title, "Line Chart")

    # Ensure data is in the expected format
    tabular_data = case data do
      %{datasets: _} = chart_data ->
        # Extract first dataset if in chart.js format
        dataset = List.first(chart_data.datasets)
        Enum.zip(chart_data.labels, dataset.data)
        |> Enum.map(fn {label, value} -> %{"category" => label, "value" => value} end)
      _ -> data
    end

    # Calculate dimensions based on data size
    data_count = if is_list(tabular_data), do: length(tabular_data), else: 5
    # Adjust width for more data points
    width = max(400, min(800, 400 + data_count * 20))
    # Adjust height to give more space
    height = max(300, min(500, 300 + data_count * 5))

    # Create line chart with tabular data and dimensions
    Tucan.lineplot(tabular_data, "category", "value", width: width, height: height)
    |> Tucan.set_title(title)
  end

  defp generate_pie_chart(data, options) do
    title = Map.get(options, :title, "Pie Chart")

    # Ensure data is in the expected format
    tabular_data = case data do
      %{datasets: _} = chart_data ->
        # Extract first dataset if in chart.js format
        dataset = List.first(chart_data.datasets)
        Enum.zip(chart_data.labels, dataset.data)
        |> Enum.map(fn {label, value} -> %{"category" => label, "value" => value} end)
      _ -> data
    end

    # For pie charts, we want a more square aspect ratio
    data_count = if is_list(tabular_data), do: length(tabular_data), else: 5
    # Calculate size based on data count, but keep it relatively square
    size = max(400, min(600, 400 + data_count * 15))

    # Use Tucan's pie chart function with dimensions
    Tucan.pie(tabular_data, width: size, height: size)
    |> Tucan.set_title(title)
  end
end
