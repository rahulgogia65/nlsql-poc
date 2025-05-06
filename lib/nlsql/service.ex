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

  @openai_key Application.compile_env(:openai_ex, :api_key)

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
        #  {:ok, sql_query} <- generate_sql_from_openai(query, schema),
        #  IO.inspect(sql_query, label: ".....sql_query"),
        sql_query = "SELECT title, total_visits FROM page_metrics ORDER BY total_visits DESC LIMIT 3;",
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
  Generate SQL directly from OpenAI based on natural language query.

  ## Parameters
  - query: The natural language query
  - schema: The database schema information

  ## Returns
  - {:ok, sql_query} if successful
  - {:error, reason} if generation fails
  """
  def generate_sql_from_openai(query, schema) do
    schema_description = Schema.to_description(schema)

    prompt = """
    Given the following database schema:
    #{schema_description}

    Convert this natural language query directly to a valid SQL query:
    "#{query}"

    Return only the SQL query without any explanation or markdown formatting.
    Ensure the query follows standard SQL syntax and uses proper table/column names from the schema.
    """

    # Create OpenAI client
    openai = OpenaiEx.new(@openai_key)

    completion =
      OpenaiEx.Chat.Completions.new(
        model: "gpt-4o",
        messages: [
          %{
            role: "system",
            content:
              "You are a specialized SQL generation engine that translates natural language to SQL queries. Respond only with the valid SQL query, nothing else."
          },
          %{role: "user", content: prompt}
        ]
      )

    case OpenaiEx.Chat.Completions.create(openai, completion) do
      {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
        # Trim the content to remove any potential whitespace/newlines
        sql_query = String.trim(content)
        {:ok, sql_query}

      {:error, %{"message" => message}} ->
        {:error, "OpenAI API error: #{message}"}

      _unexpected ->
        {:error, "Unexpected response from OpenAI"}
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
