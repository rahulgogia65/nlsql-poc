defmodule Nlsql.NLP.Schema do
  @moduledoc """
  Handles database schema information for NLP processing.
  Provides utilities to parse, format, and describe schema for better natural language understanding.
  """

  @doc """
  Parses the database schema from provided connection or configuration.
  Returns a structured schema representation.
  """
  def parse_schema(conn) do
    # Get table information from the database
    case Ecto.Adapters.SQL.query(conn, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") do
      {:ok, %{rows: tables}} ->
        tables = List.flatten(tables)

        # For each table, get its columns
        tables_with_columns =
          Enum.map(tables, fn table ->
            {:ok, %{rows: columns, columns: column_names}} =
              Ecto.Adapters.SQL.query(
                conn,
                "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_schema = 'public' AND table_name = $1",
                [table]
              )

            # Create a column map for each column
            columns_data = columns
              |> Enum.map(fn row ->
                column_data = Enum.zip(column_names, row) |> Enum.into(%{})
                %{
                  name: column_data["column_name"],
                  type: column_data["data_type"],
                  nullable: column_data["is_nullable"] == "YES"
                }
              end)

            # Return table with its columns
            %{
              name: table,
              columns: columns_data
            }
          end)

        # Get foreign key relationships
        foreign_keys = get_foreign_keys(conn)

        # Combine into final schema
        schema = %{
          tables: tables_with_columns,
          relationships: foreign_keys
        }

        {:ok, schema}

      {:error, reason} ->
        {:error, "Failed to retrieve schema: #{inspect(reason)}"}
    end
  end

  @doc """
  Converts a schema structure to a human-readable description for prompting.
  """
  def to_description(schema) do
    tables_desc = Enum.map(schema.tables, fn table ->
      columns_desc = Enum.map_join(table.columns, "\n    ", fn col ->
        nullable_str = if col.nullable, do: "nullable", else: "not nullable"
        "#{col.name} (#{col.type}, #{nullable_str})"
      end)

      """
      Table: #{table.name}
        Columns:
        #{columns_desc}
      """
    end)
    |> Enum.join("\n\n")

    relationships_desc = Enum.map_join(schema.relationships, "\n", fn rel ->
      "#{rel.table}.#{rel.column} references #{rel.references_table}.#{rel.references_column}"
    end)

    """
    #{tables_desc}

    Relationships:
    #{relationships_desc}
    """
  end

  # Helper to get foreign key relationships
  defp get_foreign_keys(conn) do
    query = """
    SELECT
      tc.table_name,
      kcu.column_name,
      ccu.table_name AS references_table,
      ccu.column_name AS references_column
    FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
    """

    case Ecto.Adapters.SQL.query(conn, query) do
      {:ok, %{rows: rows, columns: columns}} ->
        Enum.map(rows, fn row ->
          row_data = Enum.zip(columns, row) |> Enum.into(%{})
          %{
            table: row_data["table_name"],
            column: row_data["column_name"],
            references_table: row_data["references_table"],
            references_column: row_data["references_column"]
          }
        end)
      {:error, _reason} ->
        []
    end
  end
end
