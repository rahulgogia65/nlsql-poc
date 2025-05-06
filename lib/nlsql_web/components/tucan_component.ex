defmodule NlsqlWeb.Components.TucanComponent do
  use Phoenix.Component
  import Phoenix.HTML
  use PhoenixHTMLHelpers

  @doc """
  Renders a Tucan visualization component.

  ## Examples
      <.tucan_visualization
        id="my-chart"
        data={@chart_data}
        options={@chart_options}
      />
  """
  attr :id, :string, required: true
  attr :data, :map, required: true
  attr :options, :map, default: %{}
  attr :class, :string, default: ""

  def tucan_visualization(assigns) do
    # Tucan configuration
    tucan_config = Tucan.chart(assigns.data, assigns.options)
    # Render the SVG using Tucan
    svg_content = Tucan.to_svg(tucan_config)

    assigns = assign(assigns, :svg_content, svg_content)

    ~H"""
    <div
      id={@id}
      class={"tucan-visualization #{@class}"}
      phx-hook="TucanView"
      phx-update="ignore"
    >
      <%= raw(@svg_content) %>
    </div>
    """
  end
end
