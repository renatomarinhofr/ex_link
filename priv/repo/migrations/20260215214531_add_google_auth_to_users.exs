defmodule ExLink.Repo.Migrations.AddGoogleAuthToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :google_uid, :string
      add :avatar_url, :string
      add :name, :string
    end

    create unique_index(:users, [:google_uid])
  end
end
