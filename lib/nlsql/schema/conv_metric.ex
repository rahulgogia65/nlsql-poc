defmodule Nlsql.Schema.ConvMetric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "conv_metrics" do
    field :conversion_event, :string
    field :conversion_rate, :string
    field :total_conversions, :integer
    field :avg_of_pages_to_convert, :integer
    field :avg_time_to_conversion, :string
    field :avg_of_sessions_to_convert, :integer
    field :multi_session_conversion_rate, :string
    field :multi_session_conversions, :integer
    field :single_session_conversion_rate, :string
    field :single_session_conversions, :integer
    field :desktop_conversion_rate, :string
    field :desktop_conversions, :integer
    field :mobile_conversion_rate, :string
    field :mobile_conversions, :integer
    field :avg_time_on_page, :string
    field :avg_scroll_depth, :string
  end

  def changeset(conv_metric, attrs) do
    conv_metric
    |> cast(attrs, [
      :conversion_event, :conversion_rate, :total_conversions, :avg_of_pages_to_convert,
      :avg_time_to_conversion, :avg_of_sessions_to_convert, :multi_session_conversion_rate,
      :multi_session_conversions, :single_session_conversion_rate, :single_session_conversions,
      :desktop_conversion_rate, :desktop_conversions, :mobile_conversion_rate,
      :mobile_conversions, :avg_time_on_page, :avg_scroll_depth
    ])
    |> validate_required([:conversion_event])
  end
end
