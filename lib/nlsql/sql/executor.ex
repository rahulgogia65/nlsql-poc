defmodule Nlsql.SQL.Executor do
  @moduledoc """
  Executes SQL queries and returns results.
  """

  @doc """
  Execute the provided SQL query on the database.

  ## Parameters
  - sql_query: The SQL query to execute
  - repo: The Ecto repo to use for execution

  ## Returns
  - `{:ok, results}` if successful
  - `{:error, reason}` if execution fails
  """
  def execute(sql_query, repo) do
    try do
      result = Ecto.Adapters.SQL.query(repo, sql_query, [])

      case result do
        {:ok, %{rows: rows, columns: columns, num_rows: num_rows}} ->
          # Format the results into a more usable structure
          formatted_results = format_results(rows, columns)

          {:ok, %{
            results: formatted_results,
            columns: columns,
            row_count: num_rows,
            query: sql_query
          }}

        {:error, %{postgres: %{message: message}}} ->
          {:error, "Database error: #{message}"}

        {:error, reason} ->
          {:error, "Failed to execute query: #{inspect(reason)}"}
      end
    rescue
      e -> {:error, "Error executing SQL: #{Exception.message(e)}"}
    end
  end

  @doc """
  Execute the SQL query with parameters.

  ## Parameters
  - sql_query: The SQL query to execute
  - params: List of parameters to substitute in the query
  - repo: The Ecto repo to use for execution

  ## Returns
  - `{:ok, results}` if successful
  - `{:error, reason}` if execution fails
  """
  def execute_with_params(sql_query, params, repo) do
    try do
      result = Ecto.Adapters.SQL.query(repo, sql_query, params)

      case result do
        {:ok, %{rows: rows, columns: columns, num_rows: num_rows}} ->
          # Format the results into a more usable structure
          formatted_results = format_results(rows, columns)

          {:ok, %{
            results: formatted_results,
            columns: columns,
            row_count: num_rows,
            query: sql_query
          }}

        {:error, %{postgres: %{message: message}}} ->
          {:error, "Database error: #{message}"}

        {:error, reason} ->
          {:error, "Failed to execute query: #{inspect(reason)}"}
      end
    rescue
      e -> {:error, "Error executing SQL: #{Exception.message(e)}"}
    end
  end

  @doc """
  Analyze the execution plan for the provided SQL query.
  Useful for explaining query performance.

  ## Parameters
  - sql_query: The SQL query to analyze
  - repo: The Ecto repo to use for execution

  ## Returns
  - `{:ok, execution_plan}` if successful
  - `{:error, reason}` if execution fails
  """
  def explain_query(sql_query, repo) do
    explain_query = "EXPLAIN ANALYZE #{sql_query}"

    try do
      result = Ecto.Adapters.SQL.query(repo, explain_query, [])

      case result do
        {:ok, %{rows: rows}} ->
          explanation = Enum.map(rows, fn [line] -> line end)
          {:ok, explanation}

        {:error, reason} ->
          {:error, "Failed to explain query: #{inspect(reason)}"}
      end
    rescue
      e -> {:error, "Error analyzing SQL: #{Exception.message(e)}"}
    end
  end

  # Helper to format results as a list of maps
  defp format_results(rows, columns) do
    rows
    |> Enum.map(fn row ->
      Enum.zip(columns, row)
      |> Enum.into(%{})
    end)
  end
end
