defmodule ExLink.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExLink.Links` context.
  """

  @doc """
  Generate a link.
  """
  def link_fixture(attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        clicks: 42,
        expires_at: ~U[2026-02-14 18:16:00Z],
        original_url: "some original_url",
        short_code: "some short_code"
      })
      |> ExLink.Links.create_link()

    link
  end
end
