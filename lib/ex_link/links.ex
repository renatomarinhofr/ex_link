defmodule ExLink.Links do
  @moduledoc """
  The Links context.
  Public API for managing shortened links.
  """

  import Ecto.Query, warn: false
  alias ExLink.Repo
  alias ExLink.Links.Link
  alias ExLink.Accounts.Scope

  @doc """
  Returns the list of links for the given user scope.
  """
  def list_links(%Scope{user: user}) do
    Link
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single link by ID, scoped to the user.
  """
  def get_link!(%Scope{user: user}, id) do
    Link
    |> where(user_id: ^user.id)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single link by its short code (public — used for redirects).
  """
  def get_link_by_short_code(short_code) do
    Repo.get_by(Link, short_code: short_code)
  end

  @doc """
  Creates a shortened link for the given user.
  """
  def create_link(%Scope{user: user}, attrs) do
    attrs =
      attrs
      |> maybe_generate_short_code()
      |> put_user_id(user)

    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link (scoped to user).
  """
  def update_link(%Scope{user: user}, %Link{} = link, attrs) do
    if link.user_id == user.id do
      link
      |> Link.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a link (scoped to user).
  """
  def delete_link(%Scope{user: user}, %Link{} = link) do
    if link.user_id == user.id do
      Repo.delete(link)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns a changeset for tracking link changes.
  """
  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  @doc """
  Increments the click count for a link.
  """
  def increment_clicks(%Link{id: id} = link) do
    result =
      Link
      |> where(id: ^id)
      |> Repo.update_all(inc: [clicks: 1])

    broadcast_link_update(link)

    result
  end

  def subscribe(%Scope{user: user}) do
    Phoenix.PubSub.subscribe(ExLink.PubSub, "links:#{user.id}")
  end

  defp broadcast_link_update(link) do
    if link.user_id do
      Phoenix.PubSub.broadcast(ExLink.PubSub, "links:#{link.user_id}", {:link_updated, link.id})
    end
  end

  # ── Private Functions ──────────────────────────────────────

  defp maybe_generate_short_code(attrs) do
    has_code =
      Map.has_key?(attrs, :short_code) || Map.has_key?(attrs, "short_code")

    if has_code do
      attrs
    else
      key = if has_atom_keys?(attrs), do: :short_code, else: "short_code"
      Map.put(attrs, key, generate_short_code())
    end
  end

  defp has_atom_keys?(map) do
    map |> Map.keys() |> Enum.any?(&is_atom/1)
  end

  defp generate_short_code do
    code =
      :crypto.strong_rand_bytes(5)
      |> Base.url_encode64(padding: false)
      |> binary_part(0, 7)

    if Repo.get_by(Link, short_code: code) do
      generate_short_code()
    else
      code
    end
  end

  defp put_user_id(attrs, user) do
    key = if has_atom_keys?(attrs), do: :user_id, else: "user_id"
    Map.put(attrs, key, user.id)
  end
end
