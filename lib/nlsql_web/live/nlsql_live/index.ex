defmodule NlsqlWeb.NlsqlLive.Index do
  use NlsqlWeb, :live_view

  alias Nlsql.Service
  alias Nlsql.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:query, "")
      |> assign(:results, nil)
      |> assign(:loading, false)
      |> assign(:error, nil)
      |> assign(:query_history, [])
      |> assign(:show_sql, false)
      |> assign(:active_chart, nil)
      |> assign(:sample_chart_type, "bar")
      |> assign(:sample_sales_data, sample_sales_data())
      |> assign(:sample_product_data, sample_product_data())}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    socket = socket
      |> assign(:loading, true)
      |> assign(:error, nil)
      |> assign(:results, nil)

    # Process the query
    case Service.process_query(query, Repo) do
      {:ok, results} ->
        updated_history = [%{
          query: query,
          sql: results.sql_query,
          timestamp: DateTime.utc_now(),
          row_count: results.row_count
        } | socket.assigns.query_history]
        |> Enum.take(10)  # Keep only the most recent 10 queries

        {:noreply,
          socket
          |> assign(:loading, false)
          |> assign(:results, results)
          |> assign(:query_history, updated_history)
          |> assign(:active_chart, get_first_chart(results))
          |> assign(:error, nil)}

      {:error, reason} ->
        {:noreply,
          socket
          |> assign(:loading, false)
          |> assign(:error, reason)}
    end
  end

  @impl true
  def handle_event("toggle-sql", _, socket) do
    {:noreply, assign(socket, :show_sql, !socket.assigns.show_sql)}
  end

  @impl true
  def handle_event("select-chart", %{"chart-index" => index}, socket) do
    case socket.assigns.results do
      nil -> {:noreply, socket}
      results ->
        index = String.to_integer(index)
        active_chart =
          if index >= 0 and index < length(results.charts) do
            Enum.at(results.charts, index)
          else
            nil
          end
        IO.inspect(active_chart, label: "...........active_chart")
        {:noreply, assign(socket, :active_chart, active_chart)}
    end
  end

  @impl true
  def handle_event("show-sample", %{"chart-type" => chart_type}, socket) do
    {:noreply, assign(socket, :sample_chart_type, chart_type)}
  end

  @impl true
  def handle_event("tucan-visibility-change", %{"id" => _id, "visible" => _visible}, socket) do
    # Forward to the appropriate LiveComponent if needed
    {:noreply, socket}
  end

  @impl true
  def handle_event("export", %{"format" => format}, socket) do
    case socket.assigns.results do
      nil -> {:noreply, socket}
      results ->
        filename = "nlsql_export_#{DateTime.utc_now() |> DateTime.to_iso8601()}"
        content_type =
          case format do
            "csv" -> "text/csv"
            "json" -> "application/json"
            _ -> "text/plain"
          end

        {:noreply,
          socket
          |> push_event("download", %{
            filename: "#{filename}.#{format}",
            content_type: content_type,
            data: get_export_data(results, format)
          })}
    end
  end

  # Helper functions

  defp get_first_chart(results) do
    case results do
      %{charts: [first | _]} -> first
      _ -> nil
    end
  end

  defp get_export_data(results, format) do
    format_results = %{
      results: results.results,
      columns: results.columns,
      row_count: results.row_count
    }

    case Service.export_results(format_results, format) do
      {:ok, formatted_data} -> formatted_data
      {:error, _} -> ""
    end
  end

  # Sample data for Tucan charts
  defp sample_sales_data do
    [
      %{label: "Jan", value: 12500},
      %{label: "Feb", value: 17800},
      %{label: "Mar", value: 14200},
      %{label: "Apr", value: 19500},
      %{label: "May", value: 22300},
      %{label: "Jun", value: 25100}
    ]
  end

  defp sample_product_data do
    [
      %{label: "Product A", value: 32},
      %{label: "Product B", value: 45},
      %{label: "Product C", value: 27},
      %{label: "Product D", value: 18}
    ]
  end
end
