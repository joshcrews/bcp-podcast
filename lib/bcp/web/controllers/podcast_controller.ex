defmodule Bcp.Web.PodcastController do
  use Bcp.Web, :controller

  def index(conn, _params) do
    
    Bcp.EpisodeBuilderServer.build_daily_episode()

    episodes = (
                  from e in Bcp.Episode,
                  order_by: [desc: e.date]
                ) 
                |> Repo.all()

    last_build_date = if Enum.any?(episodes) && false do
                        episodes |> List.first()
                      else
                        DateTime.utc_now()
                      end

    conn
    |> assign(:episodes, episodes)
    |> assign(:last_build_date, Bcp.Web.PodcastView.pub_date(last_build_date))
    |> render("index.xml", layout: false)
  end

end
