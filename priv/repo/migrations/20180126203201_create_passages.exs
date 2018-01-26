defmodule Bcp.Repo.Migrations.CreatePassages do
  use Ecto.Migration

  def change do
    create table(:passages) do
      add :name, :string, null: false
      add :mp3_url, :string
      add :text, :text

      timestamps()
    end

    create unique_index(:passages, [:name])

  end
end
