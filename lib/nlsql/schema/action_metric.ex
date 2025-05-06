defmodule Nlsql.Schema.ActionMetric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "action_metrics" do
    field :action_event, :string
    field :clicks, :integer
    field :click_rate, :string
    field :conversion_rate, :string
    field :conversions, :integer
    field :avg_pages_to_convert, :float
    field :avg_time_to_convert, :string
    field :avg_sessions_to_convert, :float
    field :multi_session_conversion_rate, :string
    field :multi_session_conversions, :integer
    field :single_session_conversion_rate, :string
    field :single_session_conversions, :integer
    field :desktop_clicks, :integer
    field :mobile_clicks, :integer
    field :avg_time_on_page, :string
    field :avg_scroll_depth, :string
  end

  def changeset(action_metric, attrs) do
    action_metric
    |> cast(attrs, [
      :action_event, :clicks, :click_rate, :conversion_rate, :conversions,
      :avg_pages_to_convert, :avg_time_to_convert, :avg_sessions_to_convert,
      :multi_session_conversion_rate, :multi_session_conversions,
      :single_session_conversion_rate, :single_session_conversions,
      :desktop_clicks, :mobile_clicks, :avg_time_on_page, :avg_scroll_depth
    ])
    |> validate_required([:action_event])
  end
end
