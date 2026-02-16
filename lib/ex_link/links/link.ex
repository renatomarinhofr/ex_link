defmodule ExLink.Links.Link do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "links" do
    field :original_url, :string
    field :short_code, :string
    field :clicks, :integer, default: 0
    field :expires_at, :utc_datetime

    # Cada link pertence a um usuário
    belongs_to :user, ExLink.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset para criar ou atualizar um link.
  """
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:original_url, :short_code, :expires_at, :user_id])
    |> validate_required([:original_url, :short_code])
    |> validate_url(:original_url)
    |> validate_length(:short_code, min: 3, max: 20)
    |> unique_constraint(:short_code)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      uri = URI.parse(value)

      if uri.scheme in ["http", "https"] and uri.host not in [nil, ""] do
        []
      else
        [{field, "must be a valid URL starting with http:// or https://"}]
      end
    end)
  end
end
