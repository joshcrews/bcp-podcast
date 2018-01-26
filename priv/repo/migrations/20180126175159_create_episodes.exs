defmodule Bcp.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :date, :date, null: false
      add :duration_seconds, :integer
      add :mp3_url, :string
      add :passages, :string, null: false
      add :passage_text, :text

      timestamps()
    end

    create index(:episodes, :date)

  end
end
