defmodule Bcp.Repo.Migrations.AddFileSizeBytesToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :file_size_bytes, :integer
    end
  end
end
