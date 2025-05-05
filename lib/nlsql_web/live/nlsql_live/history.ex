defmodule NlsqlWeb.NlsqlLive.History do
  use NlsqlWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Retrieve query history from the database or session
    # For simplicity, we're using a mock history
    history = [
      %{
        query: "Show all customers from New York",
        sql: "SELECT * FROM customers WHERE state = 'NY'",
        timestamp: DateTime.utc_now() |> DateTime.add(-1, :hour),
        row_count: 42
      },
      %{
        query: "What were the top 5 selling products last month?",
        sql: "SELECT p.name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.id = oi.product_id JOIN orders o ON o.id = oi.order_id WHERE o.order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month') AND o.order_date < DATE_TRUNC('month', CURRENT_DATE) GROUP BY p.name ORDER BY total_sold DESC LIMIT 5",
        timestamp: DateTime.utc_now() |> DateTime.add(-3, :hour),
        row_count: 5
      },
      %{
        query: "List employees with their managers",
        sql: "SELECT e.name as employee, m.name as manager FROM employees e LEFT JOIN employees m ON e.manager_id = m.id",
        timestamp: DateTime.utc_now() |> DateTime.add(-1, :day),
        row_count: 15
      }
    ]

    {:ok, assign(socket, :history, history)}
  end

  @impl true
  def handle_event("clear_history", _params, socket) do
    # In a real application, this would clear history from database or session
    {:noreply, assign(socket, :history, [])}
  end

  @impl true
  def handle_event("re_run", %{"query" => query}, socket) do
    # Redirect to main interface with the query prefilled
    {:noreply, push_navigate(socket, to: ~p"/nlsql?query=#{URI.encode_www_form(query)}")}
  end
end
