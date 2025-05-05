defmodule NlsqlWeb.NlsqlController do
  use NlsqlWeb, :controller

  alias Nlsql.Service
  alias Nlsql.Repo

  @doc """
  Process a natural language query and return SQL results.
  """
  def process_query(conn, %{"query" => query}) do
    case Service.process_query(query, Repo) do
      {:ok, results} ->
        conn
        |> put_status(:ok)
        |> json(results)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  @doc """
  Explain an SQL query and return the execution plan.
  """
  def explain_query(conn, %{"query" => query}) do
    case Service.explain_query(query, Repo) do
      {:ok, explanation} ->
        conn
        |> put_status(:ok)
        |> json(%{explanation: explanation})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  @doc """
  Get the database schema information.
  """
  def get_schema(conn, _params) do
    case Service.get_schema(Repo) do
      {:ok, schema} ->
        conn
        |> put_status(:ok)
        |> json(%{schema: schema})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  @doc """
  Export results in specified format.
  """
  def export_results(conn, %{"results" => results, "format" => format}) do
    case Service.export_results(results, format) do
      {:ok, formatted_data} ->
        content_type =
          case format do
            "csv" -> "text/csv"
            "json" -> "application/json"
            _ -> "text/plain"
          end

        conn
        |> put_resp_content_type(content_type)
        |> send_resp(200, formatted_data)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end
end
