defmodule Nlsql.Repo do
  use Ecto.Repo,
    otp_app: :nlsql,
    adapter: Ecto.Adapters.Postgres
end
