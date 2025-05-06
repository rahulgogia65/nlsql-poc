defmodule Nlsql.Schema.PageMetric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "page_metrics" do
    field :platform_content_id, :string
    field :title, :string
    field :url, :string
    field :tags, :string
    field :publish_date, :string
    field :total_views, :integer
    field :total_visits, :integer
    field :first_touch_visits, :integer
    field :middle_touch_visits, :integer
    field :last_touch_visits, :integer
    field :single_touch_visits, :integer
    field :multi_touch_visits, :integer
    field :avg_time_on_page, :string
    field :avg_scroll_depth, :string
    field :page_recirc_rate, :string
    field :page_exit_rate, :string
    field :conversion_rate, :string
    field :total_conversions, :integer
    field :on_page_conversions, :integer
    field :on_page_conversion_rate, :string
    field :avg_ttc_w_page, :string, source: :"avg_ttc _w_page"
    field :first_touch_conversions, :integer
    field :mid_touch_conversions, :integer
    field :last_touch_conversions, :integer
    field :multi_touch_conv_rate, :string
    field :multi_touch_conversions, :integer
    field :single_touch_conv_rate, :string
    field :single_touch_conversions, :integer
    field :knotch_score, :float
    field :view_score, :float
    field :conversion_score, :float
    field :sentiment_score, :float
    field :total_responses, :float
    field :response_rate, :string
    field :positive_sentiment, :string
    field :positive_responses, :float
    field :neutral_sentiment, :string, source: :"neutral sentiment"
    field :neutral_responses, :string
    field :negative, :string, source: :"negative "
    field :negative_responses, :float
    field :top_positive_diagnostic, :float
    field :top_neutral_diagnostic, :float
    field :top_negative_diagnostic, :float
  end

  def changeset(page_metric, attrs) do
    page_metric
    |> cast(attrs, [
      :platform_content_id, :title, :url, :tags, :publish_date, :total_views, :total_visits,
      :first_touch_visits, :middle_touch_visits, :last_touch_visits, :single_touch_visits,
      :multi_touch_visits, :avg_time_on_page, :avg_scroll_depth, :page_recirc_rate, :page_exit_rate,
      :conversion_rate, :total_conversions, :on_page_conversions, :on_page_conversion_rate,
      :avg_ttc_w_page, :first_touch_conversions, :mid_touch_conversions, :last_touch_conversions,
      :multi_touch_conv_rate, :multi_touch_conversions, :single_touch_conv_rate,
      :single_touch_conversions, :knotch_score, :view_score, :conversion_score, :sentiment_score,
      :total_responses, :response_rate, :positive_sentiment, :positive_responses, :neutral_sentiment,
      :neutral_responses, :negative, :negative_responses, :top_positive_diagnostic,
      :top_neutral_diagnostic, :top_negative_diagnostic
    ])
    |> validate_required([:platform_content_id])
  end
end
