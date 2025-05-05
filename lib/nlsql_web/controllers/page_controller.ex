defmodule NlsqlWeb.PageController do
  use NlsqlWeb, :controller

  def home(conn, _params) do
    # Redirect to the NL-SQL interface
    redirect(conn, to: ~p"/nlsql")
  end
end
