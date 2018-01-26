defmodule Bcp.Passage do

  use Ecto.Schema
  import Ecto.Changeset
  alias Bcp.Passage


  schema "passages" do
    field :mp3_url, :string
    field :name, :string
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(%Passage{} = passage, attrs) do
    passage
    |> cast(attrs, [:name, :mp3_url, :text])
    |> validate_required([:name, :mp3_url, :text])
  end
end
