defmodule Nlsql.Schema.TagMetric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "tag_metrics" do
    field :child_tag, :string
    field :parent_tag, :string
    field :number_of_pages, :integer
    field :total_views, :integer
    field :average_views, :integer
    field :total_visits, :integer
    field :first_touch_visits, :integer, source: :first__touch_visits
    field :middle_touch_visits, :integer
    field :last_touch_visits, :integer, source: :last_touch__visits
    field :avg_first_touch_visits, :integer
    field :avg_middle_touch_visits, :integer
    field :avg_last_touch_visits, :integer
    field :avg_time_on_page, :string
    field :avg_scroll_depth, :string
    field :avg_exit_rate, :string
    field :avg_recirculation_rate, :string
    field :conversion_rate, :string
    field :total_conversions, :integer
    field :on_tag_conversion_rate, :string, source: :"on-tag_conversion_rate"
    field :on_tag_conversions, :integer, source: :"on-tag_conversions"
    field :avg_ttc_w_tag, :string, source: :"avg_ttc_w/_tag"
    field :first_touch_conversions, :integer
    field :mid_touch_conversions, :integer
    field :last_touch_conversions, :integer
    field :multi_touch_conv_rate, :string
    field :multi_touch_conversions, :integer
    field :single_touch_conv_rate, :string
    field :single_touch_conversions, :integer
    field :multi_session_conv_rate, :string
    field :multi_session_conversions, :integer
    field :single_session_conv_rate, :string
    field :single_session_conversions, :integer
    field :knotch_score, :float
    field :view_score, :float
    field :conversion_score, :float
    field :sentiment_score, :float
    field :total_responses, :integer
    field :response_rate, :string
    field :positive_sentiment, :string
    field :positive_responses, :integer
    field :neutral_sentiment, :string
    field :neutral_responses, :integer
    field :negative, :string
    field :negative_responses, :integer
    field :top_positive_diagnostic, :float
    field :top_neutral_diagnostic, :float
    field :top_negative_diagnostic, :float
  end

  def changeset(tag_metric, attrs) do
    tag_metric
    |> cast(attrs, [
      :child_tag, :parent_tag, :number_of_pages, :total_views, :average_views, :total_visits,
      :first_touch_visits, :middle_touch_visits, :last_touch_visits, :avg_first_touch_visits,
      :avg_middle_touch_visits, :avg_last_touch_visits, :avg_time_on_page, :avg_scroll_depth,
      :avg_exit_rate, :avg_recirculation_rate, :conversion_rate, :total_conversions,
      :on_tag_conversion_rate, :on_tag_conversions, :avg_ttc_w_tag, :first_touch_conversions,
      :mid_touch_conversions, :last_touch_conversions, :multi_touch_conv_rate,
      :multi_touch_conversions, :single_touch_conv_rate, :single_touch_conversions,
      :multi_session_conv_rate, :multi_session_conversions, :single_session_conv_rate,
      :single_session_conversions, :knotch_score, :view_score, :conversion_score, :sentiment_score,
      :total_responses, :response_rate, :positive_sentiment, :positive_responses,
      :neutral_sentiment, :neutral_responses, :negative, :negative_responses,
      :top_positive_diagnostic, :top_neutral_diagnostic, :top_negative_diagnostic
    ])
    |> validate_required([:child_tag])
  end
end
