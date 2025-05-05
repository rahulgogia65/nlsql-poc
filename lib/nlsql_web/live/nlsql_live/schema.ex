defmodule NlsqlWeb.NlsqlLive.Schema do
  use NlsqlWeb, :live_view

  alias Nlsql.Service
  alias Nlsql.Repo

  @impl true
  def mount(_params, _session, socket) do
    # Fetch database schema
    case Service.get_schema(Repo) do
      {:ok, schema} ->
        {:ok,
          socket
          |> assign(:schema, schema)
          |> assign(:error, nil)
          |> assign(:selected_table, nil)}

      {:error, reason} ->
        {:ok,
          socket
          |> assign(:schema, nil)
          |> assign(:error, reason)
          |> assign(:selected_table, nil)}
    end
  end

  @impl true
  def handle_event("select_table", %{"table" => table_name}, socket) do
    selected_table =
      Enum.find(socket.assigns.schema.tables, fn table ->
        table.name == table_name
      end)

    {:noreply, assign(socket, :selected_table, selected_table)}
  end

  # Helper function to get related tables through foreign keys
  def get_related_tables(schema, table_name) do
    schema.relationships
    |> Enum.filter(fn rel ->
      rel.table == table_name or rel.references_table == table_name
    end)
    |> Enum.map(fn rel ->
      if rel.table == table_name do
        %{
          table: rel.references_table,
          relation: "#{rel.table}.#{rel.column} → #{rel.references_table}.#{rel.references_column}"
        }
      else
        %{
          table: rel.table,
          relation: "#{rel.table}.#{rel.column} → #{rel.references_table}.#{rel.references_column}"
        }
      end
    end)
    |> Enum.uniq_by(fn rel -> rel.table end)
  end
end
