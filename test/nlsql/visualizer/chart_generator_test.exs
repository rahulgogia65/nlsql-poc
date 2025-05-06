defmodule Nlsql.Visualizer.ChartGeneratorTest do
  use ExUnit.Case
  alias Nlsql.Visualizer.ChartGenerator

  describe "generate_tucan_chart/2" do
    test "generates a bar chart with valid data" do
      # Sample data structure as expected by chart functions
      data = %{
        data: [
          %{"x" => "Category A", "y" => 10},
          %{"x" => "Category B", "y" => 25},
          %{"x" => "Category C", "y" => 15}
        ],
        labels: %{
          x: "Categories",
          y: "Values"
        }
      }

      chart_config = ChartGenerator.generate_tucan_chart(data, "bar")

      # Assert it's a valid Tucan chart configuration
      assert %Tucan.Chart{} = chart_config
      # We could add more specific assertions based on Tucan.Chart structure
    end

    test "generates a line chart with valid data" do
      # Sample data structure as expected by chart functions
      data = %{
        data: [
          %{"x" => "Jan", "y" => 10},
          %{"x" => "Feb", "y" => 25},
          %{"x" => "Mar", "y" => 15}
        ],
        labels: %{
          x: "Month",
          y: "Revenue"
        }
      }

      chart_config = ChartGenerator.generate_tucan_chart(data, "line")

      # Assert it's a valid Tucan chart configuration
      assert %Tucan.Chart{} = chart_config
    end

    test "generates a pie chart with valid data" do
      # Sample data structure as expected by chart functions
      data = %{
        data: [
          %{"x" => "Product A", "y" => 30},
          %{"x" => "Product B", "y" => 45},
          %{"x" => "Product C", "y" => 25}
        ],
        labels: %{
          x: "Products",
          y: "Sales"
        }
      }

      chart_config = ChartGenerator.generate_tucan_chart(data, "pie")

      # Assert it returns a VegaLite chart for pie charts
      assert %VegaLite.Graph{} = chart_config
    end

    test "returns nil for invalid data" do
      # Test with nil data
      assert ChartGenerator.generate_tucan_chart(nil, "bar") == nil

      # Test with empty data
      assert ChartGenerator.generate_tucan_chart(%{data: []}, "bar") == nil

      # Test with missing data key
      assert ChartGenerator.generate_tucan_chart(%{}, "bar") == nil
    end

    test "defaults to bar chart for unknown chart type" do
      data = %{
        data: [
          %{"x" => "Category A", "y" => 10},
          %{"x" => "Category B", "y" => 25}
        ],
        labels: %{
          x: "Categories",
          y: "Values"
        }
      }

      chart_config = ChartGenerator.generate_tucan_chart(data, "unknown_type")

      # Should default to bar chart
      assert %Tucan.Chart{} = chart_config
    end
  end
end
