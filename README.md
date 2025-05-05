# Natural Language to SQL (NLSQL)

A powerful Elixir/Phoenix application that converts natural language queries into SQL. This application uses OpenAI's GPT models to interpret natural language, generate appropriate SQL queries, and execute them against your database.

## Features

- Convert natural language to SQL queries
- Visualize query results with interactive charts
- Browse your database schema
- View query history
- Export results in CSV or JSON formats
- Explain SQL query execution plans

## Prerequisites

- Elixir 1.14 or later
- Phoenix 1.7 or later
- PostgreSQL database
- OpenAI API key

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/nlsql.git
   cd nlsql
   ```

2. Install dependencies:
   ```
   mix deps.get
   ```

3. Install JavaScript dependencies:
   ```
   mix deps.npm
   ```

4. Configure your database in `config/dev.exs`

5. Set up your OpenAI API key:
   ```
   export OPENAI_API_KEY=your_api_key_here
   ```

6. Create and migrate your database:
   ```
   mix ecto.setup
   ```

7. Start the Phoenix server:
   ```
   mix phx.server
   ```

8. Visit http://localhost:4000 in your browser

## Usage

1. Start by visiting the main interface at `/nlsql`
2. Enter a natural language query, for example:
   - "Show me all customers from New York"
   - "What were the top 5 selling products last month?"
   - "Count the number of orders placed in January 2023 grouped by status"
3. The system will:
   - Parse your query using OpenAI
   - Generate the appropriate SQL
   - Execute the query against your database
   - Display the results in a table
   - Suggest visualizations based on the data
   
## How It Works

1. **Natural Language Processing**: Your query is sent to OpenAI's API along with your database schema to extract query parameters.
2. **SQL Generation**: The extracted parameters are used to generate a valid SQL query.
3. **Execution**: The generated SQL is executed against your database.
4. **Visualization**: The results are analyzed to suggest appropriate chart visualizations.

## Screenshots

[Add screenshots here]

## Technologies Used

- Elixir/Phoenix for backend
- LiveView for interactive UI without writing JavaScript
- OpenAI GPT for natural language processing
- Chart.js for data visualization
- PostgreSQL for data storage
- TailwindCSS for styling

## License

[Your License Here]
