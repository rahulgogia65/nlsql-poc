defmodule NlsqlWeb.SurveyResultsLive do
  use NlsqlWeb, :live_view
  alias NlsqlWeb.Components.VegaLiteComponent
  alias NlsqlWeb.Helpers.VegaLiteSpecs

  @impl true
  def mount(_params, _session, socket) do
    # Sample survey questions and results
    questions = [
      %{
        "id" => "q1",
        "type" => "Single-choice",
        "question" => "What is your preferred programming language?",
        "options" => [
          %{"label" => "Elixir", "count" => 120},
          %{"label" => "JavaScript", "count" => 85},
          %{"label" => "Python", "count" => 95},
          %{"label" => "Rust", "count" => 65},
          %{"label" => "Go", "count" => 45}
        ]
      },
      %{
        "id" => "q2",
        "type" => "Range",
        "question" => "How many years of experience do you have?",
        "options" => [
          %{"label" => "0-1", "count" => 42},
          %{"label" => "2-3", "count" => 78},
          %{"label" => "4-5", "count" => 63},
          %{"label" => "6-10", "count" => 51},
          %{"label" => "10+", "count" => 36}
        ]
      },
      %{
        "id" => "q3",
        "type" => "Single-choice",
        "question" => "Which database do you use most often?",
        "options" => [
          %{"label" => "PostgreSQL", "count" => 110},
          %{"label" => "MySQL", "count" => 75},
          %{"label" => "MongoDB", "count" => 65},
          %{"label" => "SQLite", "count" => 45},
          %{"label" => "Other", "count" => 25}
        ]
      }
    ]

    socket =
      socket
      |> assign(:page_title, "Survey Results")
      |> assign(:questions, questions)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-2xl font-bold mb-6">Survey Results</h1>

      <div class="space-y-8">
        <%= for question <- @questions do %>
          <div class="bg-white p-6 rounded-lg shadow-md">
            <h2 class="text-xl font-semibold mb-2"><%= question["question"] %></h2>
            <p class="text-gray-600 mb-4">Question type: <%= question["type"] %></p>

            <%= case question["type"] do %>
              <% "Range" -> %>
                <.live_component
                  module={VegaLiteComponent}
                  id={"graph_#{question["id"]}"}
                  spec={range_choice_spec(question["options"])}
                  class="w-full h-64"
                />

              <% "Single-choice" -> %>
                <.live_component
                  module={VegaLiteComponent}
                  id={"graph_#{question["id"]}"}
                  spec={single_choice_spec(question["options"])}
                  class="w-full h-64"
                />
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Function to generate a bar chart spec for range questions
  defp range_choice_spec(options) do
    # Convert options to the format expected by VegaLiteSpecs
    data = Enum.map(options, fn opt ->
      %{"category" => opt["label"], "value" => opt["count"]}
    end)

    VegaLiteSpecs.bar_chart_spec(data,
      title: "Response Distribution",
      colors: ["#4C72B0"]
    )
  end

  # Function to generate a pie chart spec for single choice questions
  defp single_choice_spec(options) do
    # Convert options to the format expected by VegaLiteSpecs
    data = Enum.map(options, fn opt ->
      %{"category" => opt["label"], "value" => opt["count"]}
    end)

    VegaLiteSpecs.pie_chart_spec(data,
      title: "Response Distribution",
      colors: ["#4C72B0", "#55A868", "#C44E52", "#8172B3", "#937860"]
    )
  end
end
