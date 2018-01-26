defmodule Bcp.Web.Router do
  use Bcp.Web, :router

  pipeline :xml do
    plug :accepts, ["xml"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bcp.Web do
    pipe_through :xml # Use the default xml stack

    get "/podcast.xml", PodcastController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bcp.Web do
  #   pipe_through :api
  # end
end
