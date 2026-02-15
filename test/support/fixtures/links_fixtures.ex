defmodule ExLink.LinksFixtures do
  @moduledoc """
  Factory de links para testes.
  Tipo um createMockLink() no JS.
  """

  @doc """
  Cria um link no banco com dados padrão.
  Aceita attrs pra sobrescrever qualquer campo.

  ## Exemplos

      link_fixture()                                          # Dados padrão
      link_fixture(%{original_url: "https://custom.com"})     # URL customizada
  """
  def link_fixture(attrs \\ %{}) do
    # Gera um short_code único pra cada fixture (evita conflito de unique_constraint)
    unique_code = "test_#{System.unique_integer([:positive])}"

    {:ok, link} =
      attrs
      |> Enum.into(%{
        original_url: "https://example.com",
        short_code: unique_code
      })
      |> ExLink.Links.create_link()

    link
  end
end
