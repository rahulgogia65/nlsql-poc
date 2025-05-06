--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action_metrics; Type: TABLE; Schema: public; Owner: prashantkumar
--

CREATE TABLE public.action_metrics (
    action_event text,
    clicks bigint,
    click_rate text,
    conversion_rate text,
    conversions bigint,
    avg_pages_to_convert double precision,
    avg_time_to_convert text,
    avg_sessions_to_convert double precision,
    multi_session_conversion_rate text,
    multi_session_conversions bigint,
    single_session_conversion_rate text,
    single_session_conversions bigint,
    desktop_clicks bigint,
    mobile_clicks bigint,
    avg_time_on_page text,
    avg_scroll_depth text
);


ALTER TABLE public.action_metrics OWNER TO prashantkumar;

--
-- Name: conv_metrics; Type: TABLE; Schema: public; Owner: prashantkumar
--

CREATE TABLE public.conv_metrics (
    conversion_event text,
    conversion_rate text,
    total_conversions bigint,
    avg_of_pages_to_convert bigint,
    avg_time_to_conversion text,
    avg_of_sessions_to_convert bigint,
    multi_session_conversion_rate text,
    multi_session_conversions bigint,
    single_session_conversion_rate text,
    single_session_conversions bigint,
    desktop_conversion_rate text,
    desktop_conversions bigint,
    mobile_conversion_rate text,
    mobile_conversions bigint,
    avg_time_on_page text,
    avg_scroll_depth text
);


ALTER TABLE public.conv_metrics OWNER TO prashantkumar;

--
-- Name: page_metrics; Type: TABLE; Schema: public; Owner: prashantkumar
--

CREATE TABLE public.page_metrics (
    platform_content_id text,
    title text,
    url text,
    tags text,
    publish_date text,
    total_views bigint,
    total_visits bigint,
    first_touch_visits bigint,
    middle_touch_visits bigint,
    last_touch_visits bigint,
    single_touch_visits bigint,
    multi_touch_visits bigint,
    avg_time_on_page text,
    avg_scroll_depth text,
    page_recirc_rate text,
    page_exit_rate text,
    conversion_rate text,
    total_conversions bigint,
    on_page_conversions bigint,
    on_page_conversion_rate text,
    "avg_ttc _w_page" text,
    first_touch_conversions bigint,
    mid_touch_conversions bigint,
    last_touch_conversions bigint,
    multi_touch_conv_rate text,
    multi_touch_conversions bigint,
    single_touch_conv_rate text,
    single_touch_conversions bigint,
    knotch_score double precision,
    view_score double precision,
    conversion_score double precision,
    sentiment_score double precision,
    total_responses double precision,
    response_rate text,
    positive_sentiment text,
    positive_responses double precision,
    "neutral sentiment" text,
    neutral_responses text,
    "negative " text,
    negative_responses double precision,
    top_positive_diagnostic double precision,
    top_neutral_diagnostic double precision,
    top_negative_diagnostic double precision
);


ALTER TABLE public.page_metrics OWNER TO prashantkumar;

--
-- Name: tag_metrics; Type: TABLE; Schema: public; Owner: prashantkumar
--

CREATE TABLE public.tag_metrics (
    child_tag text,
    parent_tag text,
    number_of_pages bigint,
    total_views bigint,
    average_views bigint,
    total_visits bigint,
    first__touch_visits bigint,
    middle_touch_visits bigint,
    last_touch__visits bigint,
    avg_first_touch_visits bigint,
    avg_middle_touch_visits bigint,
    avg_last_touch_visits bigint,
    avg_time_on_page text,
    avg_scroll_depth text,
    avg_exit_rate text,
    avg_recirculation_rate text,
    conversion_rate text,
    total_conversions bigint,
    "on-tag_conversion_rate" text,
    "on-tag_conversions" bigint,
    "avg_ttc_w/_tag" text,
    first_touch_conversions bigint,
    mid_touch_conversions bigint,
    last_touch_conversions bigint,
    multi_touch_conv_rate text,
    multi_touch_conversions bigint,
    single_touch_conv_rate text,
    single_touch_conversions bigint,
    multi_session_conv_rate text,
    multi_session_conversions bigint,
    single_session_conv_rate text,
    single_session_conversions bigint,
    knotch_score double precision,
    view_score double precision,
    conversion_score double precision,
    sentiment_score double precision,
    total_responses bigint,
    response_rate text,
    positive_sentiment text,
    positive_responses bigint,
    neutral_sentiment text,
    neutral_responses bigint,
    negative text,
    negative_responses bigint,
    top_positive_diagnostic double precision,
    top_neutral_diagnostic double precision,
    top_negative_diagnostic double precision
);


ALTER TABLE public.tag_metrics OWNER TO prashantkumar;

--
-- PostgreSQL database dump complete
--

