defmodule NlsqlWeb.Router do
  use NlsqlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NlsqlWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NlsqlWeb do
    pipe_through :browser

    get "/", PageController, :home

    # NL to SQL Live View routes
    live "/nlsql", NlsqlLive.Index, :index
    live "/nlsql/history", NlsqlLive.History, :index
    live "/nlsql/schema", NlsqlLive.Schema, :index
  end

  # API routes for NL to SQL service
  scope "/api", NlsqlWeb do
    pipe_through :api

    post "/nlsql/query", NlsqlController, :process_query
    post "/nlsql/explain", NlsqlController, :explain_query
    get "/nlsql/schema", NlsqlController, :get_schema
    post "/nlsql/export", NlsqlController, :export_results
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:nlsql, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NlsqlWeb.Telemetry
    end
  end
end
