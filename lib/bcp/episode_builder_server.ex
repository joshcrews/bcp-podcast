defmodule Bcp.EpisodeBuilderServer do

  @moduledoc """
  The point of the genserver is to make sequential (not parallel) the requests
  to generate the next episode, and never have that happen in parallel
  """

  use GenServer

  alias Bcp.Repo

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :episode_builder_server)
  end

  def init(_) do
    {:ok, []}
  end

  def build_daily_episode() do
    GenServer.cast(:episode_builder_server, :build_daily_episode)
  end


  ### Server Callbacks

  
  def handle_info(:build_daily_episode, _state) do
    work()
    {:noreply, []}
  end


  def work do
    date = Date.utc_today()

    case Repo.get_by(Bcp.Episode, %{date: date}) do
      nil ->
        Bcp.EpisodeBuilder.build(date)
      _ ->
        :noop
    end
  end

end


