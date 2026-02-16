defmodule ExLink.Repo.Migrations.AddUserIdToLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
    end

    create index(:links, [:user_id])
  end
end
