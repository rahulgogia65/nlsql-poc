defmodule NlsqlWeb.ChartController do
  use NlsqlWeb, :controller

  @doc """
  Generates and serves a chart image on-the-fly using Tucan.
  Chart configuration is passed via query parameters.
  """
  def show(conn, %{"chart_data" => chart_data_base64}) do
    with {:ok, chart_data_json} <- Base.decode64(chart_data_base64),
         {:ok, chart_data} <- Jason.decode(chart_data_json) do

      # Generate chart based on type
      chart = generate_chart(chart_data)

      # Render chart to binary
      {:ok, image_binary} = Tucan.to_png(chart)

      # Send image as response
      conn
      |> put_resp_content_type("image/png")
      |> send_resp(200, image_binary)
    else
      _ ->
        conn
        |> put_resp_content_type("image/png")
        |> send_resp(400, "Invalid chart data")
    end
  end

  # Generate chart based on the chart type
  defp generate_chart(%{"type" => chart_type} = chart_data) do
    labels = get_labels(chart_data)
    values = get_values(chart_data)
    title = get_title(chart_data)

    case chart_type do
      "bar" -> generate_bar_chart(labels, values, title)
      "line" -> generate_line_chart(labels, values, title)
      "pie" -> generate_pie_chart(labels, values, title)
      _ -> generate_bar_chart(labels, values, title) # Default to bar chart
    end
  end

  # Fallback for missing chart type
  defp generate_chart(chart_data) do
    labels = get_labels(chart_data)
    values = get_values(chart_data)
    title = get_title(chart_data)

    generate_bar_chart(labels, values, title)
  end

  # Extract labels from chart data
  defp get_labels(%{"data" => %{"labels" => labels}}), do: labels
  defp get_labels(_), do: []

  # Extract values from chart data
  defp get_values(%{"data" => %{"datasets" => [%{"data" => values} | _]}}), do: values
  defp get_values(_), do: []

  # Extract title from chart data
  defp get_title(%{"options" => %{"plugins" => %{"title" => %{"text" => text}}}}), do: text
  defp get_title(_), do: "Chart"

  # Generate a bar chart using Tucan
  defp generate_bar_chart(labels, values, title) do
    # Check if we have valid data
    if Enum.empty?(labels) || Enum.empty?(values) || length(labels) != length(values) do
      # Return a simple empty chart
      Tucan.canvas()
      |> Tucan.set_title("No data available")
    else
      # Convert values to float to ensure consistency
      parsed_values = Enum.map(values, fn v ->
        case v do
          v when is_binary(v) ->
            case Float.parse(v) do
              {float_val, _} -> float_val
              :error -> 0.0
            end
          v when is_number(v) -> v * 1.0
          _ -> 0.0
        end
      end)

      # Ensure we have matching data points
      zipped_data = Enum.zip(labels, parsed_values)

      # Check if we have any data points after parsing
      if Enum.empty?(zipped_data) do
        Tucan.canvas()
        |> Tucan.set_title("No valid data available")
      else
        # Create data in tabular format required by Tucan
        data = Enum.map(zipped_data, fn {label, value} ->
          %{"category" => label, "value" => value}
        end)

        # Ensure data is not empty
        if Enum.empty?(data) do
          Tucan.canvas()
          |> Tucan.set_title("No valid data available")
        else
          # Create bar chart with tabular data
          Tucan.bar(data, "category", "value")
          |> Tucan.set_title(title)
        end
      end
    end
  end

  # Generate a line chart using Tucan
  defp generate_line_chart(labels, values, title) do
    # Check if we have valid data
    if Enum.empty?(labels) || Enum.empty?(values) || length(labels) != length(values) do
      # Return a simple empty chart
      Tucan.canvas()
      |> Tucan.set_title("No data available")
    else
      # Convert values to float to ensure consistency
      parsed_values = Enum.map(values, fn v ->
        case v do
          v when is_binary(v) ->
            case Float.parse(v) do
              {float_val, _} -> float_val
              :error -> 0.0
            end
          v when is_number(v) -> v * 1.0
          _ -> 0.0
        end
      end)

      # Ensure we have matching data points
      zipped_data = Enum.zip(labels, parsed_values)

      # Check if we have any data points after parsing
      if Enum.empty?(zipped_data) do
        Tucan.canvas()
        |> Tucan.set_title("No valid data available")
      else
        # Create data in tabular format required by Tucan
        data = Enum.map(zipped_data, fn {label, value} ->
          %{"category" => label, "value" => value}
        end)

        # Ensure data is not empty
        if Enum.empty?(data) do
          Tucan.canvas()
          |> Tucan.set_title("No valid data available")
        else
          # Create line chart with tabular data
          Tucan.lineplot(data, "category", "value")
          |> Tucan.set_title(title)
        end
      end
    end
  end

  # Generate a pie chart using Tucan
  defp generate_pie_chart(labels, values, title) do
    # Check if we have valid data
    if Enum.empty?(labels) || Enum.empty?(values) || length(labels) != length(values) do
      # Return a simple empty chart
      Tucan.canvas()
      |> Tucan.set_title("No data available")
    else
      # Convert values to float to ensure consistency
      parsed_values = Enum.map(values, fn v ->
        case v do
          v when is_binary(v) ->
            case Float.parse(v) do
              {float_val, _} -> float_val
              :error -> 0.0
            end
          v when is_number(v) -> v * 1.0
          _ -> 0.0
        end
      end)

      # Ensure we have matching data points
      zipped_data = Enum.zip(labels, parsed_values)

      # Check if we have any data points after parsing
      if Enum.empty?(zipped_data) do
        Tucan.canvas()
        |> Tucan.set_title("No valid data available")
      else
        # Create data in tabular format required by Tucan
        data = Enum.map(zipped_data, fn {label, value} ->
          %{"category" => label, "value" => value}
        end)

        # Ensure data is not empty
        if Enum.empty?(data) do
          Tucan.canvas()
          |> Tucan.set_title("No valid data available")
        else
          # Create a donut chart since Tucan doesn't have a direct pie chart function
          canvas = Tucan.canvas(width: 400, height: 400)

          # Use VegaLite directly for the pie chart
          VegaLite.new()
          |> VegaLite.data_from_values(data)
          |> VegaLite.encode_field(:theta, "value", type: :quantitative)
          |> VegaLite.encode_field(:color, "category", type: :nominal)
          |> VegaLite.mark(:arc)
          |> VegaLite.config(view: [stroke: nil])
          |> VegaLite.properties(title: title)
        end
      end
    end
  end
end
