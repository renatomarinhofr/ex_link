defmodule ExLink.Repo.Migrations.AddLinksConstraints do
  use Ecto.Migration

  def change do
    # Índice único no short_code (garante que não repete)
    create unique_index(:links, [:short_code])

    # Default 0 para clicks
    alter table(:links) do
      modify :clicks, :integer, default: 0
    end
  end
end
