defmodule Bcp.Web.PageController do
  use Bcp.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
