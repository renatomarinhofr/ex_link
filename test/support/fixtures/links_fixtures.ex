defmodule ExLink.LinksFixtures do
  @moduledoc """
  Factory de links para testes.
  """

  import ExLink.AccountsFixtures

  def link_fixture(attrs \\ %{}) do
    # Se não passou um scope, cria um usuário novo
    scope = attrs[:scope] || scope_fixture()
    attrs = Map.delete(attrs, :scope)

    unique_code = "test_#{System.unique_integer([:positive])}"

    {:ok, link} =
      attrs
      |> Enum.into(%{
        original_url: "https://example.com",
        short_code: unique_code
      })
      |> then(&ExLink.Links.create_link(scope, &1))

    link
  end

  def scope_fixture do
    user = user_fixture()
    ExLink.Accounts.Scope.for_user(user)
  end
end
