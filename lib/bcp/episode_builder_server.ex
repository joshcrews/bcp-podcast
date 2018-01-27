defmodule Bcp.EpisodeBuilderServer do

  import Ecto.Query
  alias Bcp.Repo

  @moduledoc """
  The point of the genserver is to make sequential (not parallel) the requests
  to generate the next episode, and never have that happen in parallel
  """

  use GenServer

  

  def start_link do
    IO.inspect {:started, :episode_builder_server}
    GenServer.start_link(__MODULE__, nil, name: :episode_builder_server)
  end

  def init(_) do
    {:ok, []}
  end

  def build_daily_episode() do
    GenServer.cast(:episode_builder_server, :build_daily_episode)
  end


  ### Server Callbacks

  
  def handle_cast(:build_daily_episode, _state) do
    IO.inspect({:work, :build_daily_episode})
    work()
    {:noreply, []}
  end


  def work do
    date = Date.utc_today()
    query = (
              from e in Bcp.Episode,
              where: e.date == ^date
            )

    case Repo.all(query) do
      [] ->
        Bcp.EpisodeBuilder.build(date)
      _ ->
        :noop
    end
  end

end


