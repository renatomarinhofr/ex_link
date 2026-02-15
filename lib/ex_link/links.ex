defmodule ExLink.Links do
  @moduledoc """
  The Links context.
  Public API for managing shortened links.
  """

  import Ecto.Query, warn: false
  alias ExLink.Repo
  alias ExLink.Links.Link

  @doc """
  Returns the list of links ordered by most recent.

  ## Examples

      iex> list_links()
      [%Link{}, ...]
  """
  def list_links do
    Link
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single link by ID.
  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!("some-uuid")
      %Link{}
  """
  def get_link!(id), do: Repo.get!(Link, id)

  @doc """
  Gets a single link by its short code.
  Returns `nil` if not found.

  This is the main function used for redirects:
  user visits /abc123 → we find the link by short_code "abc123" → redirect to original_url

  ## Examples

      iex> get_link_by_short_code("abc123")
      %Link{}

      iex> get_link_by_short_code("nonexistent")
      nil
  """
  def get_link_by_short_code(short_code) do
    Repo.get_by(Link, short_code: short_code)
  end

  @doc """
  Creates a shortened link.
  Automatically generates a unique short_code if not provided.

  ## Examples

      iex> create_link(%{original_url: "https://google.com"})
      {:ok, %Link{short_code: "aB3kZ9"}}

      iex> create_link(%{original_url: "invalid"})
      {:error, %Ecto.Changeset{}}
  """
  def create_link(attrs) do
    attrs = maybe_generate_short_code(attrs)

    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link.
  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.
  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.
  """
  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  @doc """
  Increments the click count for a link.
  Uses atomic update to avoid race conditions.

  ## Examples

      iex> increment_clicks(link)
      {1, nil}
  """
  def increment_clicks(%Link{id: id} = link) do
    result =
      Link
      |> where(id: ^id)
      |> Repo.update_all(inc: [clicks: 1])

    # Avisa todo mundo que está escutando: "esse link foi clicado!"
    broadcast_link_update(link)

    result
  end

  @doc """
  Subscribe to link updates (used by LiveViews).
  """
  def subscribe do
    Phoenix.PubSub.subscribe(ExLink.PubSub, "links")
  end

  defp broadcast_link_update(link) do
    Phoenix.PubSub.broadcast(ExLink.PubSub, "links", {:link_updated, link.id})
  end

  # ── Private Functions ──────────────────────────────────────

  # If no short_code is provided, generate one
  defp maybe_generate_short_code(attrs) do
    has_code =
      Map.has_key?(attrs, :short_code) || Map.has_key?(attrs, "short_code")

    if has_code do
      attrs
    else
      # Usa o mesmo tipo de chave que já existe no map
      key = if has_atom_keys?(attrs), do: :short_code, else: "short_code"
      Map.put(attrs, key, generate_short_code())
    end
  end

  defp has_atom_keys?(map) do
    map |> Map.keys() |> Enum.any?(&is_atom/1)
  end

  # Generates a random 7-character alphanumeric code
  # and checks for uniqueness
  defp generate_short_code do
    code =
      :crypto.strong_rand_bytes(5)
      |> Base.url_encode64(padding: false)
      |> binary_part(0, 7)

    # If code already exists, try again (recursive)
    if Repo.get_by(Link, short_code: code) do
      generate_short_code()
    else
      code
    end
  end
end
