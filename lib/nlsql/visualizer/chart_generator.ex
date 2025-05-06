defmodule Nlsql.Visualizer.ChartGenerator do
  @moduledoc """
  Generates chart configurations for visualizing SQL query results.
  """

  @doc """
  Suggest appropriate chart types based on the SQL results.

  ## Parameters
  - results: The results from SQL execution

  ## Returns
  - List of recommended chart types with suitable columns
  """
  def suggest_chart_types(results) do
    columns = results.columns
    data = results.results

    # Identify numeric columns
    numeric_columns = identify_numeric_columns(data, columns)

    # Identify categorical columns (good for x-axis)
    categorical_columns = identify_categorical_columns(data, columns)

    # Make chart suggestions
    suggestions = []

    # Bar chart suggestions
    bar_suggestions =
      if length(categorical_columns) > 0 and length(numeric_columns) > 0 do
        Enum.map(numeric_columns, fn num_col ->
          x_axis = List.first(categorical_columns)
          %{
            chart_type: "bar",
            x_axis: x_axis,
            y_axis: num_col,
            title: "#{format_column_name(x_axis)} by #{format_column_name(num_col)}"
          }
        end)
      else
        []
      end

    # Line chart suggestions (if there's a date column)
    date_columns = identify_date_columns(data, columns)
    line_suggestions =
      if length(date_columns) > 0 and length(numeric_columns) > 0 do
        Enum.map(numeric_columns, fn num_col ->
          x_axis = List.first(date_columns)
          %{
            chart_type: "line",
            x_axis: x_axis,
            y_axis: num_col,
            title: "#{format_column_name(num_col)} over Time"
          }
        end)
      else
        []
      end

    # Pie chart suggestions (for single numeric column with categories)
    pie_suggestions =
      if length(categorical_columns) > 0 and length(numeric_columns) > 0 and length(data) <= 10 do
        Enum.map(numeric_columns, fn num_col ->
          x_axis = List.first(categorical_columns)
          %{
            chart_type: "pie",
            x_axis: x_axis,
            y_axis: num_col,
            title: "Distribution of #{format_column_name(num_col)} by #{format_column_name(x_axis)}"
          }
        end)
      else
        []
      end

    # Combine all suggestions
    suggestions
    |> Enum.concat(bar_suggestions)
    |> Enum.concat(line_suggestions)
    |> Enum.concat(pie_suggestions)
    |> Enum.uniq()
  end

  @doc """
  Generate configuration for a bar chart.

  ## Parameters
  - data: The formatted data for chart visualization

  ## Returns
  - Chart.js configuration for a bar chart or nil if data is empty
  """
  def generate_bar_chart(data) do
    # Return nil if data is empty or invalid
    if !data || !Map.has_key?(data, :data) || Enum.empty?(data.data) do
      nil
    else
      labels = Enum.map(data.data, fn point -> point["x"] end)
      values = Enum.map(data.data, fn point -> point["y"] end)

      %{
        type: "bar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: data.labels.y,
              data: values,
              backgroundColor: generate_colors(length(values)),
              borderWidth: 1
            }
          ]
        },
        options: %{
          responsive: true,
          plugins: %{
            legend: %{
              position: "top"
            },
            title: %{
              display: true,
              text: "#{data.labels.y} by #{data.labels.x}"
            }
          },
          scales: %{
            y: %{
              beginAtZero: true,
              title: %{
                display: true,
                text: data.labels.y
              }
            },
            x: %{
              title: %{
                display: true,
                text: data.labels.x
              }
            }
          }
        }
      }
    end
  end

  @doc """
  Generate configuration for a line chart.

  ## Parameters
  - data: The formatted data for chart visualization

  ## Returns
  - Chart.js configuration for a line chart or nil if data is empty
  """
  def generate_line_chart(data) do
    # Return nil if data is empty or invalid
    if !data || !Map.has_key?(data, :data) || Enum.empty?(data.data) do
      nil
    else
      labels = Enum.map(data.data, fn point -> point["x"] end)
      values = Enum.map(data.data, fn point -> point["y"] end)

      %{
        type: "line",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: data.labels.y,
              data: values,
              fill: false,
              borderColor: "rgb(75, 192, 192)",
              tension: 0.1
            }
          ]
        },
        options: %{
          responsive: true,
          plugins: %{
            legend: %{
              position: "top"
            },
            title: %{
              display: true,
              text: "#{data.labels.y} over Time"
            }
          },
          scales: %{
            y: %{
              beginAtZero: true,
              title: %{
                display: true,
                text: data.labels.y
              }
            },
            x: %{
              title: %{
                display: true,
                text: data.labels.x
              }
            }
          }
        }
      }
    end
  end

  @doc """
  Generate configuration for a pie chart.

  ## Parameters
  - data: The formatted data for chart visualization

  ## Returns
  - Chart.js configuration for a pie chart or nil if data is empty
  """
  def generate_pie_chart(data) do
    # Return nil if data is empty or invalid
    if !data || !Map.has_key?(data, :data) || Enum.empty?(data.data) do
      nil
    else
      labels = Enum.map(data.data, fn point -> point["x"] end)
      values = Enum.map(data.data, fn point -> point["y"] end)

      %{
        type: "pie",
        data: %{
          labels: labels,
          datasets: [
            %{
              data: values,
              backgroundColor: generate_colors(length(values)),
              hoverOffset: 4
            }
          ]
        },
        options: %{
          responsive: true,
          plugins: %{
            legend: %{
              position: "top"
            },
            title: %{
              display: true,
              text: "Distribution of #{data.labels.y}"
            }
          }
        }
      }
    end
  end

  # Helper functions

  # Identify columns that contain numeric data
  defp identify_numeric_columns(data, columns) do
    Enum.filter(columns, fn col ->
      # Check first few rows to identify if the column is numeric
      sample = Enum.take(data, min(5, length(data)))

      Enum.all?(sample, fn row ->
        value = Map.get(row, col)
        is_number(value) or
          (is_binary(value) and String.match?(value, ~r/^-?\d+(\.\d+)?$/))
      end)
    end)
  end

  # Identify columns that are good categorical variables (non-numeric with few unique values)
  defp identify_categorical_columns(data, columns) do
    Enum.filter(columns, fn col ->
      # Get all unique values for this column
      unique_values = data |> Enum.map(fn row -> Map.get(row, col) end) |> Enum.uniq()

      # A good categorical column has relatively few unique values (less than 20% of rows)
      length(unique_values) <= max(10, length(data) * 0.2) and
        # And is not primarily numeric
        not Enum.all?(Enum.take(data, min(5, length(data))), fn row ->
          value = Map.get(row, col)
          is_number(value) or
            (is_binary(value) and String.match?(value, ~r/^-?\d+(\.\d+)?$/))
        end)
    end)
  end

  # Identify columns that contain date values
  defp identify_date_columns(data, columns) do
    Enum.filter(columns, fn col ->
      # Check first few rows to identify if the column is a date
      sample = Enum.take(data, min(5, length(data)))

      Enum.all?(sample, fn row ->
        value = Map.get(row, col)
        case value do
          %DateTime{} -> true
          %Date{} -> true
          %NaiveDateTime{} -> true
          value when is_binary(value) ->
            # Try to parse as ISO date
            String.match?(value, ~r/^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2})?/)
          _ -> false
        end
      end)
    end)
  end

  # Generate colors for chart elements
  defp generate_colors(count) do
    base_colors = [
      "rgba(255, 99, 132, 0.6)",
      "rgba(54, 162, 235, 0.6)",
      "rgba(255, 206, 86, 0.6)",
      "rgba(75, 192, 192, 0.6)",
      "rgba(153, 102, 255, 0.6)",
      "rgba(255, 159, 64, 0.6)",
      "rgba(199, 199, 199, 0.6)",
      "rgba(83, 102, 255, 0.6)",
      "rgba(40, 159, 143, 0.6)",
      "rgba(210, 105, 30, 0.6)"
    ]

    # If we need more colors than in our base set, we'll cycle through them
    Enum.map(0..(count-1), fn i ->
      Enum.at(base_colors, rem(i, length(base_colors)))
    end)
  end

  # Format column names for display
  defp format_column_name(column_name) when is_binary(column_name) do
    column_name
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_column_name(column_name), do: "#{column_name}"

  @doc """
  Generate configuration for a Tucan bar chart.

  ## Parameters
  - data: The formatted data for chart visualization

  ## Returns
  - Tucan configuration for a bar chart or nil if data is empty
  """
  def generate_tucan_bar_chart(data) do
    # Return nil if data is empty or invalid
    if !data || !Map.has_key?(data, :data) || Enum.empty?(data.data) do
      nil
    else
      # Create data in tabular format required by Tucan
      tabular_data = Enum.map(data.data, fn point ->
        %{"category" => point["x"], "value" => point["y"]}
      end)

      # Calculate dimensions based on data size
      data_count = length(tabular_data)
      # Adjust width for more data points
      width = max(400, min(800, 400 + data_count * 20))
      # Adjust height to give more space for labels when many data points
      height = max(300, min(600, 300 + data_count * 10))

      # Create bar chart with tabular data and set dimensions
      tabular_data
      Tucan.bar(tabular_data, "category", "value", width: width, height: height)
      |> Tucan.set_title("#{data.labels.y} by #{data.labels.x}")
    end
  end

  @doc """
  Generate configuration for a Tucan line chart.

  ## Parameters
  - data: The formatted data for chart visualization

  ## Returns
  - Tucan configuration for a line chart or nil if data is empty
  """
  def generate_tucan_line_chart(data) do
    # Return nil if data is empty or invalid
    if !data || !Map.has_key?(data, :data) || Enum.empty?(data.data) do
      nil
    else
      # Create data in tabular format required by Tucan
      tabular_data = Enum.map(data.data, fn point ->
        %{"category" => point["x"], "value" => point["y"]}
      end)

      # Calculate dimensions based on data size
      data_count = length(tabular_data)
      # Adjust width for more data points
      width = max(400, min(800, 400 + data_count * 20))
      # Adjust height to give more space
      height = max(300, min(500, 300 + data_count * 5))

      # Create line chart with tabular data and dimensions
      Tucan.lineplot(tabular_data, "category", "value", width: width, height: height)
      |> Tucan.set_title("#{data.labels.y} over Time")
    end
  end

  @doc """
  Generate configuration for a Tucan pie chart.

  ## Parameters
  - data: The formatted data for chart visualization

  ## Returns
  - Tucan configuration for a pie chart or nil if data is empty
  """
  def generate_tucan_pie_chart(data) do
    # Return nil if data is empty or invalid
    if !data || !Map.has_key?(data, :data) || Enum.empty?(data.data) do
      nil
    else
      # Create data in tabular format required by Tucan
      tabular_data = Enum.map(data.data, fn point ->
        %{"category" => point["x"], "value" => point["y"]}
      end)

      # For pie charts, we want a more square aspect ratio
      data_count = length(tabular_data)
      # Calculate size based on data count, but keep it relatively square
      size = max(400, min(600, 400 + data_count * 15))

      # Use Tucan for pie chart with appropriate dimensions
      Tucan.pie(tabular_data, "category", "value", width: size, height: size)
      |> Tucan.set_title("Distribution of #{data.labels.y}")
    end
  end

  @doc """
  Generate a Tucan chart based on the chart type.

  ## Parameters
  - data: The formatted data for chart visualization
  - chart_type: The type of chart to generate ("bar", "line", or "pie")

  ## Returns
  - Tucan chart configuration or nil if data is empty
  """
  def generate_tucan_chart(data, chart_type) do
    case chart_type do
      "bar" -> generate_tucan_bar_chart(data)
      "line" -> generate_tucan_line_chart(data)
      "pie" -> generate_tucan_pie_chart(data)
      _ -> generate_tucan_bar_chart(data) # Default to bar chart
    end
  end
end
