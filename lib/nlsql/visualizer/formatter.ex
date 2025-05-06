defmodule Nlsql.Visualizer.Formatter do
  @moduledoc """
  Formats SQL query results for different types of visualizations.
  """

  @doc """
  Format SQL results for table visualization.

  ## Parameters
  - results: The results from SQL execution

  ## Returns
  - Formatted data for table visualization
  """
  def format_for_table(results) do
    columns = results.columns

    # Map the column names to display versions (with proper capitalization)
    display_columns = Enum.map(columns, fn col ->
      %{
        field: col,
        headerName: format_column_name(col),
        sortable: true,
        filter: true
      }
    end)

    # Format the row data
    rows = Enum.map(results.results, fn row ->
      # Ensure all values are properly formatted for JSON representation
      row |> Enum.map(fn {k, v} -> {k, format_value(v)} end) |> Enum.into(%{})
    end)

    %{
      columns: display_columns,
      rows: rows,
      totalRows: results.row_count
    }
  end

  @doc """
  Format SQL results for chart visualization.

  ## Parameters
  - results: The results from SQL execution
  - chart_type: The type of chart to create (bar, line, pie)
  - x_axis: The column to use for the x-axis
  - y_axis: The column to use for the y-axis

  ## Returns
  - Formatted data for chart visualization
  """
  def format_for_chart(results, chart_type, x_axis, y_axis) do
    # Handle nil or empty results
    if !results || !Map.has_key?(results, :results) || Enum.empty?(results.results) ||
       !x_axis || !y_axis ||
       (is_list(results.columns) && (!Enum.member?(results.columns, x_axis) || !Enum.member?(results.columns, y_axis))) do
      # Return a minimal valid structure that will be caught by the chart generators
      %{
        type: chart_type,
        data: [],
        labels: %{
          x: x_axis && format_column_name(x_axis) || "X Axis",
          y: y_axis && format_column_name(y_axis) || "Y Axis"
        }
      }
    else
      data = Enum.map(results.results, fn row ->
        x_value = Map.get(row, x_axis)
        y_value =
          case Map.get(row, y_axis) do
            value when is_binary(value) ->
              case Float.parse(value) do
                {num, _} -> num
                :error -> 0
              end
            value when is_number(value) -> value
            _ -> 0
          end

        %{
          "x" => format_value(x_value),
          "y" => y_value
        }
      end)

      %{
        type: chart_type,
        data: data,
        labels: %{
          x: format_column_name(x_axis),
          y: format_column_name(y_axis)
        }
      }
    end
  end

  @doc """
  Format SQL results as CSV.

  ## Parameters
  - results: The results from SQL execution

  ## Returns
  - CSV formatted string
  """
  def format_as_csv(results) do
    header = Enum.join(results.columns, ",")

    rows = Enum.map(results.results, fn row ->
      values = Enum.map(results.columns, fn col ->
        value = Map.get(row, col, "")
        format_csv_value(value)
      end)
      Enum.join(values, ",")
    end)

    [header | rows] |> Enum.join("\n")
  end

  @doc """
  Format SQL results as JSON.

  ## Parameters
  - results: The results from SQL execution

  ## Returns
  - JSON string
  """
  def format_as_json(results) do
    Jason.encode!(results.results)
  end

  @doc """
  Format query and results for display in the UI.

  ## Parameters
  - query: The SQL query
  - results: The results from SQL execution

  ## Returns
  - Formatted data for UI display
  """
  def format_for_display(query, results) do
    %{
      query: query,
      columns: results.columns,
      rows: results.results,
      row_count: results.row_count,
      execution_time: Map.get(results, :execution_time, 0)
    }
  end

  # Helper functions

  # Format a column name for display (capitalize, replace underscores with spaces)
  defp format_column_name(column_name) when is_binary(column_name) do
    column_name
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  # Handle non-string column names
  defp format_column_name(column_name), do: "#{column_name}"

  # Format a value for output, handling nil, dates, and other types
  defp format_value(nil), do: nil
  defp format_value(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp format_value(%Date{} = d), do: Date.to_iso8601(d)
  defp format_value(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_iso8601(ndt)
  defp format_value(value), do: value

  # Escape and format a value for CSV
  defp format_csv_value(nil), do: ""
  defp format_csv_value(value) when is_binary(value) do
    if String.contains?(value, [",", "\"", "\n"]) do
      "\"#{String.replace(value, "\"", "\"\"")}\""
    else
      value
    end
  end
  defp format_csv_value(value), do: "#{value}"
end
