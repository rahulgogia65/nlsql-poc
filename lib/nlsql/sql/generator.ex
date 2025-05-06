defmodule Nlsql.SQL.Generator do
  @moduledoc """
  SQL generator that converts parsed NLP data into executable SQL queries.
  """

  @doc """
  Generate SQL query from parsed NLP data.

  ## Parameters
  - parsed_data: The structured data from the NLP parser
  - schema: The database schema information

  ## Returns
  - `{:ok, sql_query}` if successful
  - `{:error, reason}` if generation fails
  """
  def generate(parsed_data, schema) do
      intent = Map.get(parsed_data, "intent", "select")

      sql_query = case String.downcase(intent) do
        "select" -> generate_select(parsed_data, schema)
        "insert" -> generate_insert(parsed_data, schema)
        "update" -> generate_update(parsed_data, schema)
        "delete" -> generate_delete(parsed_data, schema)
        _ -> {:error, "Unsupported SQL operation: #{intent}"}
      end

      case sql_query do
        {:ok, query} -> {:ok, query}
        {:error, reason} -> {:error, reason}
        res -> res
      end
  end

  # Generate a SELECT query
  defp generate_select(parsed_data, _schema) do
    tables = Map.get(parsed_data, "Entities", [])
    columns = Map.get(parsed_data, "Columns", ["*"])
    filters = Map.get(parsed_data, "FilterConditions", nil)
    sort = Map.get(parsed_data, "Sorting", nil)
    group_by = Map.get(parsed_data, "Grouping", nil)
    limit = Map.get(parsed_data, "Limit", nil)

    # Build the SELECT clause
    select_clause = "SELECT #{format_columns(columns)}"

    # Build the FROM clause
    from_clause = if tables == [] do
      {:error, "No tables specified for SELECT query"}
    else
      {:ok, "FROM #{Enum.join(tables, ", ")}"}
    end

    # Build the WHERE clause
    where_clause =
      if filters do
        "WHERE #{format_filters(filters)}"
      else
        ""
      end

    # Build the GROUP BY clause
    group_clause =
      if group_by do
        "GROUP BY #{Enum.join(group_by, ", ")}"
      else
        ""
      end

    # Build the ORDER BY clause
    order_clause =
      if sort do
        "ORDER BY #{format_sort(sort)}"
      else
        ""
      end

    # Build the LIMIT clause
    limit_clause =
      if limit do
        "LIMIT #{limit}"
      else
        ""
      end

    # Combine all clauses
    case from_clause do
      {:ok, from} ->
        query_parts = [
          select_clause,
          from,
          where_clause,
          group_clause,
          order_clause,
          limit_clause
        ]
        |> Enum.filter(fn part -> part != "" end)
        |> Enum.join(" ")

        {:ok, query_parts}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Generate an INSERT query
  defp generate_insert(parsed_data, _schema) do
    tables = Map.get(parsed_data, "entities", [])

    if length(tables) != 1 do
      {:error, "INSERT requires exactly one table"}
    else
      table = List.first(tables)
      columns = Map.get(parsed_data, "columns", [])
      values = Map.get(parsed_data, "values", [])

      if columns == [] or values == [] do
        {:error, "INSERT requires columns and values"}
      else
        if length(columns) != length(values) do
          {:error, "Number of columns and values must match"}
        else
          formatted_columns = Enum.join(columns, ", ")
          formatted_values = Enum.map_join(values, ", ", fn v -> "'#{v}'" end)

          query = "INSERT INTO #{table} (#{formatted_columns}) VALUES (#{formatted_values})"
          {:ok, query}
        end
      end
    end
  end

  # Generate an UPDATE query
  defp generate_update(parsed_data, _schema) do
    tables = Map.get(parsed_data, "entities", [])

    if length(tables) != 1 do
      {:error, "UPDATE requires exactly one table"}
    else
      table = List.first(tables)
      columns = Map.get(parsed_data, "columns", [])
      values = Map.get(parsed_data, "values", [])
      filters = Map.get(parsed_data, "filter_conditions", nil)

      if columns == [] or values == [] do
        {:error, "UPDATE requires columns and values"}
      else
        if length(columns) != length(values) do
          {:error, "Number of columns and values must match"}
        else
          updates = Enum.zip(columns, values)
            |> Enum.map_join(", ", fn {col, val} -> "#{col} = '#{val}'" end)

          where_clause =
            if filters do
              "WHERE #{format_filters(filters)}"
            else
              ""
            end

          query = "UPDATE #{table} SET #{updates} #{where_clause}"
          {:ok, query}
        end
      end
    end
  end

  # Generate a DELETE query
  defp generate_delete(parsed_data, _schema) do
    tables = Map.get(parsed_data, "entities", [])

    if length(tables) != 1 do
      {:error, "DELETE requires exactly one table"}
    else
      table = List.first(tables)
      filters = Map.get(parsed_data, "filter_conditions", nil)

      where_clause =
        if filters do
          "WHERE #{format_filters(filters)}"
        else
          ""
        end

      query = "DELETE FROM #{table} #{where_clause}"
      {:ok, query}
    end
  end

  # Helper function to format columns
  defp format_columns(columns) when is_list(columns) do
    Enum.join(columns, ", ")
  end

  defp format_columns(columns) when is_binary(columns) do
    columns
  end

  defp format_columns(_) do
    "*"
  end

  # Helper function to format filter conditions
  defp format_filters(filters) when is_list(filters) do
    Enum.join(filters, " AND ")
  end

  defp format_filters(filters) when is_binary(filters) do
    filters
  end

  defp format_filters(filters) when is_map(filters) do
    Enum.map_join(filters, " AND ", fn {k, v} -> "#{k} = '#{v}'" end)
  end

  # Helper function to format sorting
  defp format_sort(sort) when is_list(sort) do
    Enum.join(sort, ", ")
  end

  defp format_sort(sort) when is_binary(sort) do
    sort
  end

  defp format_sort(sort) when is_map(sort) do
    Enum.map_join(sort, ", ", fn {column, direction} -> "#{column} #{direction}" end)
  end
end
