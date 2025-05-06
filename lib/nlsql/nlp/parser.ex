defmodule Nlsql.NLP.Parser do
  @moduledoc """
  Parses natural language queries and extracts relevant information for SQL generation.
  Uses OpenAI's API for processing the input.
  """

  alias Nlsql.NLP.Schema

  @openai_key Application.compile_env(:openai_ex, :api_key)

  @doc """
  Process the natural language query using the OpenAI API.

  Returns a structured map of extracted information with entity recognition,
  intent identification, and query parameters.
  """
  def parse(query, schema) do
    case parse_with_openai(query, schema) do
      {:ok, parsed_data} -> {:ok, parsed_data}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_with_openai(query, schema) do
    schema_description = Schema.to_description(schema)

    prompt = """
    Given the following database schema:
    #{schema_description}

    Convert this natural language query to SQL extraction parameters:
    "#{query}"

    Extract the following information in JSON format:
    1. Entities (tables) mentioned
    2. Columns/fields required
    3. Filter conditions
    4. Sorting requirements (if any)
    5. Grouping requirements (if any)
    6. Limit (if specified)
    7. The identified intent (select, insert, update, delete)
    """

    # Fetch openai key from config
    openai = OpenaiEx.new(@openai_key)

    completion =
      OpenaiEx.Chat.Completions.new(
        model: "gpt-4o",
        messages: [
          %{
            role: "system",
            content:
              "You are a specialized NLP engine for translating natural language to SQL query parameters. Respond only with valid JSON."
          },
          %{role: "user", content: prompt}
        ],
        response_format: %{type: "json_object"}
      )

    result = OpenaiEx.Chat.Completions.create(openai, completion)

    case result do
      {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
        parsed_json = Jason.decode!(content)
        {:ok, parsed_json}

      {:error, %{"message": message}} ->
        {:error, "OpenAI API error: #{message}"}

      _ ->
        {:error, "Unexpected response from OpenAI"}
    end
  end
end
