defmodule Bcp.Episode do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bcp.Episode


  schema "episodes" do
    field :date, :date
    field :duration_seconds, :integer
    field :mp3_url, :string
    field :passage_text, :string
    field :passages, :string

    timestamps()
  end

  @doc false
  def changeset(%Episode{} = episode, attrs) do
    episode
    |> cast(attrs, [:date, :duration_seconds, :mp3_url, :passages, :passage_text])
    |> validate_required([:date, :duration_seconds, :mp3_url, :passages, :passage_text])
  end
end
