defmodule Nlsql.Service do
  @moduledoc """
  Main service module that coordinates the NLP to SQL workflow.
  """

  alias Nlsql.NLP.Parser
  alias Nlsql.NLP.Schema
  alias Nlsql.SQL.Generator
  alias Nlsql.SQL.Executor
  alias Nlsql.Visualizer.Formatter
  alias Nlsql.Visualizer.ChartGenerator

  @doc """
  Process a natural language query to SQL.

  ## Parameters
  - query: The natural language query
  - conn: The database connection

  ## Returns
  - Results including SQL, execution output, and visualization suggestions
  """
  def process_query(query, repo) do
    with {:ok, schema} <- Schema.parse_schema(repo),
         {:ok, parsed_data} <- Parser.parse(query, schema),
         {:ok, sql_query} <- Generator.generate(parsed_data, schema),
         {:ok, results} <- Executor.execute(sql_query, repo) do

      # Format results for visualization
      table_data = Formatter.format_for_table(results)

      # Generate chart suggestions
      chart_suggestions = ChartGenerator.suggest_chart_types(results)

      # Process chart suggestions to create actual chart configs for the top suggestions
      charts =
        chart_suggestions
        |> Enum.take(3)  # Take top 3 suggestions
        |> Enum.map(fn suggestion ->
          chart_data = Formatter.format_for_chart(
            results,
            suggestion.chart_type,
            suggestion.x_axis,
            suggestion.y_axis
          )

          chart_config =
            case suggestion.chart_type do
              "bar" -> ChartGenerator.generate_bar_chart(chart_data)
              "line" -> ChartGenerator.generate_line_chart(chart_data)
              "pie" -> ChartGenerator.generate_pie_chart(chart_data)
              _ -> nil
            end

          %{
            type: suggestion.chart_type,
            title: suggestion.title,
            config: chart_config
          }
        end)
        |> Enum.filter(fn chart -> chart.config != nil end)

      # Return comprehensive result
      {:ok, %{
        original_query: query,
        parsed_data: parsed_data,
        sql_query: sql_query,
        results: results.results,
        columns: results.columns,
        row_count: results.row_count,
        table_data: table_data,
        charts: charts
      }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get explanation for an SQL query.

  ## Parameters
  - sql_query: The SQL query to explain
  - repo: The database connection

  ## Returns
  - Explanation of the query execution plan
  """
  def explain_query(sql_query, repo) do
    Executor.explain_query(sql_query, repo)
  end

  @doc """
  Export results in different formats.

  ## Parameters
  - results: The SQL execution results
  - format: The export format ("csv", "json")

  ## Returns
  - Formatted data in the requested format
  """
  def export_results(results, format) do
    case format do
      "csv" -> {:ok, Formatter.format_as_csv(results)}
      "json" -> {:ok, Formatter.format_as_json(results)}
      _ -> {:error, "Unsupported export format: #{format}"}
    end
  end

  @doc """
  Get database schema information.

  ## Parameters
  - repo: The database connection

  ## Returns
  - Database schema in a structured format
  """
  def get_schema(repo) do
    Schema.parse_schema(repo)
  end
end
