defmodule NlsqlWeb.NlsqlLive.Visualization do
  use NlsqlWeb, :live_view
  alias NlsqlWeb.Components.TucanComponent
  import NlsqlWeb.Components.TucanComponent

  @impl true
  def mount(_params, _session, socket) do
    # Sample data for visualization
    chart_data = %{
      labels: ["January", "February", "March", "April", "May"],
      datasets: [
        %{
          label: "Sample Data",
          data: [10, 25, 15, 30, 20]
        }
      ]
    }

    chart_options = %{
      title: "Sample Visualization",
      type: "bar",  # or "line", "pie", etc. based on Tucan's capabilities
      colors: ["#4C72B0", "#55A868", "#C44E52"]
    }

    socket =
      socket
      |> assign(:page_title, "Visualization")
      |> assign(:chart_data, chart_data)
      |> assign(:chart_options, chart_options)

    {:ok, socket}
  end

  @impl true
  def handle_event("tucan-interaction", %{"type" => type, "data" => data}, socket) do
    # Handle interaction events from the client
    IO.inspect({type, data}, label: "Tucan interaction")
    {:noreply, socket}
  end
end
