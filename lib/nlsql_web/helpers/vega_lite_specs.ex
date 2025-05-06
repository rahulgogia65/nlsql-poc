defmodule NlsqlWeb.Helpers.VegaLiteSpecs do
  @moduledoc """
  Helper functions for generating Vega-Lite chart specifications.
  """

  @doc """
  Generates a bar chart specification from the given data.

  ## Examples

      iex> bar_chart_spec([%{"category" => "A", "value" => 28}, %{"category" => "B", "value" => 55}])
      %{
        "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
        "data" => %{"values" => [%{"category" => "A", "value" => 28}, %{"category" => "B", "value" => 55}]},
        "mark" => "bar",
        "encoding" => %{
          "x" => %{"field" => "category", "type" => "nominal"},
          "y" => %{"field" => "value", "type" => "quantitative"}
        }
      }
  """
  def bar_chart_spec(data, opts \\ []) do
    title = Keyword.get(opts, :title)
    x_field = Keyword.get(opts, :x_field, "category")
    y_field = Keyword.get(opts, :y_field, "value")
    colors = Keyword.get(opts, :colors)

    spec = %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => data},
      "mark" => "bar",
      "encoding" => %{
        "x" => %{"field" => x_field, "type" => "nominal"},
        "y" => %{"field" => y_field, "type" => "quantitative"}
      }
    }

    # Add optional configurations
    spec
    |> maybe_add_title(title)
    |> maybe_add_colors(colors)
  end

  @doc """
  Generates a line chart specification from the given data.

  ## Examples

      iex> line_chart_spec([%{"date" => "2021-01", "value" => 28}, %{"date" => "2021-02", "value" => 55}])
      %{
        "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
        "data" => %{"values" => [%{"date" => "2021-01", "value" => 28}, %{"date" => "2021-02", "value" => 55}]},
        "mark" => "line",
        "encoding" => %{
          "x" => %{"field" => "date", "type" => "temporal"},
          "y" => %{"field" => "value", "type" => "quantitative"}
        }
      }
  """
  def line_chart_spec(data, opts \\ []) do
    title = Keyword.get(opts, :title)
    x_field = Keyword.get(opts, :x_field, "category")
    y_field = Keyword.get(opts, :y_field, "value")
    colors = Keyword.get(opts, :colors)
    # Default to temporal type if the x_field contains "date" or "time"
    x_type = if String.contains?(x_field, ["date", "time"]), do: "temporal", else: "nominal"

    spec = %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => data},
      "mark" => "line",
      "encoding" => %{
        "x" => %{"field" => x_field, "type" => x_type},
        "y" => %{"field" => y_field, "type" => "quantitative"}
      }
    }

    # Add optional configurations
    spec
    |> maybe_add_title(title)
    |> maybe_add_colors(colors)
  end

  @doc """
  Generates a pie chart specification from the given data.

  ## Examples

      iex> pie_chart_spec([%{"category" => "A", "value" => 28}, %{"category" => "B", "value" => 55}])
      %{
        "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
        "data" => %{"values" => [%{"category" => "A", "value" => 28}, %{"category" => "B", "value" => 55}]},
        "mark" => {"type" => "arc", "innerRadius" => 0},
        "encoding" => %{
          "theta" => %{"field" => "value", "type" => "quantitative"},
          "color" => %{"field" => "category", "type" => "nominal"}
        },
        "view" => %{"stroke" => nil}
      }
  """
  def pie_chart_spec(data, opts \\ []) do
    title = Keyword.get(opts, :title)
    category_field = Keyword.get(opts, :category_field, "category")
    value_field = Keyword.get(opts, :value_field, "value")
    colors = Keyword.get(opts, :colors)

    spec = %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => data},
      "mark" => %{"type" => "arc", "innerRadius" => 0},
      "encoding" => %{
        "theta" => %{"field" => value_field, "type" => "quantitative"},
        "color" => %{"field" => category_field, "type" => "nominal"}
      },
      "view" => %{"stroke" => nil}
    }

    # Add optional configurations
    spec
    |> maybe_add_title(title)
    |> maybe_add_colors(colors)
  end

  # Helper functions for adding optional configuration
  defp maybe_add_title(spec, nil), do: spec
  defp maybe_add_title(spec, title), do: Map.put(spec, "title", title)

  defp maybe_add_colors(spec, nil), do: spec
  defp maybe_add_colors(spec, colors) do
    put_in(spec, ["encoding", "color", "scale"], %{"range" => colors})
  end
end
