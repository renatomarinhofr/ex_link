defmodule ExLink.LinksTest do
  use ExLink.DataCase

  alias ExLink.Links
  alias ExLink.Links.Link

  import ExLink.LinksFixtures

  # Cria um scope (usuário) pra cada teste
  setup do
    scope = scope_fixture()
    %{scope: scope}
  end

  describe "list_links/1" do
    test "retorna lista vazia quando não há links", %{scope: scope} do
      assert Links.list_links(scope) == []
    end

    test "retorna apenas links do usuário", %{scope: scope} do
      link_fixture(%{scope: scope, original_url: "https://meu-link.com"})

      # Link de outro usuário — não deve aparecer
      link_fixture(%{original_url: "https://outro-usuario.com"})

      links = Links.list_links(scope)
      assert length(links) == 1
      assert hd(links).original_url == "https://meu-link.com"
    end
  end

  describe "get_link!/2" do
    test "retorna o link pelo ID (scoped)", %{scope: scope} do
      link = link_fixture(%{scope: scope})
      assert Links.get_link!(scope, link.id) == link
    end

    test "não retorna link de outro usuário", %{scope: scope} do
      other_link = link_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Links.get_link!(scope, other_link.id)
      end
    end
  end

  describe "get_link_by_short_code/1" do
    test "retorna o link pelo short_code (público)", %{scope: scope} do
      link = link_fixture(%{scope: scope, short_code: "meucode"})
      assert Links.get_link_by_short_code("meucode").id == link.id
    end

    test "retorna nil quando short_code não existe" do
      assert Links.get_link_by_short_code("naoexiste") == nil
    end
  end

  describe "create_link/2" do
    test "cria link com dados válidos", %{scope: scope} do
      attrs = %{original_url: "https://elixir-lang.org", short_code: "elixir"}

      assert {:ok, %Link{} = link} = Links.create_link(scope, attrs)
      assert link.original_url == "https://elixir-lang.org"
      assert link.short_code == "elixir"
      assert link.clicks == 0
      assert link.user_id == scope.user.id
    end

    test "gera short_code automaticamente", %{scope: scope} do
      attrs = %{original_url: "https://google.com"}

      assert {:ok, %Link{} = link} = Links.create_link(scope, attrs)
      assert link.short_code != nil
      assert String.length(link.short_code) == 7
    end

    test "rejeita URL inválida", %{scope: scope} do
      attrs = %{original_url: "nao-sou-url", short_code: "test123"}

      assert {:error, changeset} = Links.create_link(scope, attrs)
      assert %{original_url: ["must be a valid URL starting with http:// or https://"]} =
               errors_on(changeset)
    end

    test "rejeita short_code duplicado", %{scope: scope} do
      link_fixture(%{scope: scope, short_code: "duplicado"})

      attrs = %{original_url: "https://outro.com", short_code: "duplicado"}

      assert {:error, changeset} = Links.create_link(scope, attrs)
      assert %{short_code: ["has already been taken"]} = errors_on(changeset)
    end

    test "rejeita URL vazia", %{scope: scope} do
      attrs = %{original_url: "", short_code: "test123"}

      assert {:error, changeset} = Links.create_link(scope, attrs)
      assert %{original_url: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "delete_link/2" do
    test "deleta o link do próprio usuário", %{scope: scope} do
      link = link_fixture(%{scope: scope})

      assert {:ok, %Link{}} = Links.delete_link(scope, link)

      assert_raise Ecto.NoResultsError, fn ->
        Links.get_link!(scope, link.id)
      end
    end

    test "não deleta link de outro usuário", %{scope: scope} do
      other_link = link_fixture()

      assert {:error, :unauthorized} = Links.delete_link(scope, other_link)
    end
  end

  describe "increment_clicks/1" do
    test "incrementa o contador de cliques", %{scope: scope} do
      link = link_fixture(%{scope: scope})
      assert link.clicks == 0

      Links.increment_clicks(link)

      updated = Links.get_link!(scope, link.id)
      assert updated.clicks == 1
    end
  end
end
