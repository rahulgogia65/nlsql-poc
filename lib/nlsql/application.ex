defmodule Nlsql.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NlsqlWeb.Telemetry,
      Nlsql.Repo,
      {DNSCluster, query: Application.get_env(:nlsql, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Nlsql.PubSub},
      {Finch, name: Nlsql.Finch},
      # Start a worker by calling: Nlsql.Worker.start_link(arg)
      # {Nlsql.Worker, arg},
      # Start to serve requests, typically the last entry
      NlsqlWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nlsql.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NlsqlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
