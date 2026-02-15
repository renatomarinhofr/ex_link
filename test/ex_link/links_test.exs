defmodule ExLink.LinksTest do
  # DataCase configura o banco em modo sandbox:
  # cada teste roda numa transaction que é revertida no final.
  # Isso significa que testes não interferem entre si.
  use ExLink.DataCase

  alias ExLink.Links
  alias ExLink.Links.Link

  # Importa a fixture pra criar links rápido nos testes
  import ExLink.LinksFixtures

  # ── describe ─────────────────────────────────────────────
  # Agrupa testes relacionados. Tipo describe() do Jest/Vitest.
  # Cada describe testa uma função do Context.

  describe "list_links/0" do
    test "retorna lista vazia quando não há links" do
      assert Links.list_links() == []
    end

    test "retorna todos os links" do
      link_fixture(%{original_url: "https://first.com"})
      link_fixture(%{original_url: "https://second.com"})

      links = Links.list_links()
      assert length(links) == 2

      urls = Enum.map(links, & &1.original_url)
      assert "https://first.com" in urls
      assert "https://second.com" in urls
    end
  end

  describe "get_link!/1" do
    test "retorna o link pelo ID" do
      link = link_fixture()
      assert Links.get_link!(link.id) == link
    end

    test "lança erro se o link não existe" do
      fake_id = Ecto.UUID.generate()

      # assert_raise = espera que a função lance uma exception
      # Tipo expect(() => fn()).toThrow() no Jest
      assert_raise Ecto.NoResultsError, fn ->
        Links.get_link!(fake_id)
      end
    end
  end

  describe "get_link_by_short_code/1" do
    test "retorna o link pelo short_code" do
      link = link_fixture(%{short_code: "meucode"})
      assert Links.get_link_by_short_code("meucode") == link
    end

    test "retorna nil quando short_code não existe" do
      assert Links.get_link_by_short_code("naoexiste") == nil
    end
  end

  describe "create_link/1" do
    test "cria link com dados válidos" do
      attrs = %{original_url: "https://elixir-lang.org", short_code: "elixir"}

      # Pattern matching no retorno — {:ok, %Link{}}
      assert {:ok, %Link{} = link} = Links.create_link(attrs)
      assert link.original_url == "https://elixir-lang.org"
      assert link.short_code == "elixir"
      assert link.clicks == 0
      assert link.expires_at == nil
    end

    test "gera short_code automaticamente quando não informado" do
      attrs = %{original_url: "https://google.com"}

      assert {:ok, %Link{} = link} = Links.create_link(attrs)
      assert link.short_code != nil
      assert String.length(link.short_code) == 7
    end

    test "rejeita URL inválida" do
      attrs = %{original_url: "nao-sou-url", short_code: "test123"}

      assert {:error, changeset} = Links.create_link(attrs)

      # errors_on/1 retorna um map de erros por campo
      # É um helper do DataCase — muito útil pra asserts de validação
      assert %{original_url: ["must be a valid URL starting with http:// or https://"]} =
               errors_on(changeset)
    end

    test "rejeita short_code menor que 3 caracteres" do
      attrs = %{original_url: "https://google.com", short_code: "ab"}

      assert {:error, changeset} = Links.create_link(attrs)
      assert %{short_code: [msg]} = errors_on(changeset)
      assert msg =~ "should be at least 3"
    end

    test "rejeita short_code duplicado" do
      link_fixture(%{short_code: "duplicado"})

      attrs = %{original_url: "https://outro.com", short_code: "duplicado"}

      assert {:error, changeset} = Links.create_link(attrs)
      assert %{short_code: ["has already been taken"]} = errors_on(changeset)
    end

    test "rejeita URL sem protocolo http/https" do
      attrs = %{original_url: "ftp://files.com/doc", short_code: "test123"}

      assert {:error, changeset} = Links.create_link(attrs)
      assert %{original_url: [_msg]} = errors_on(changeset)
    end

    test "rejeita quando original_url está vazio" do
      attrs = %{original_url: "", short_code: "test123"}

      assert {:error, changeset} = Links.create_link(attrs)
      assert %{original_url: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "update_link/2" do
    test "atualiza link com dados válidos" do
      link = link_fixture()

      assert {:ok, updated} = Links.update_link(link, %{original_url: "https://new-url.com"})
      assert updated.original_url == "https://new-url.com"
    end

    test "rejeita atualização com dados inválidos" do
      link = link_fixture()

      assert {:error, _changeset} = Links.update_link(link, %{original_url: "invalido"})

      # Garante que o link original não foi alterado
      assert Links.get_link!(link.id).original_url == link.original_url
    end
  end

  describe "delete_link/1" do
    test "deleta o link" do
      link = link_fixture()

      assert {:ok, %Link{}} = Links.delete_link(link)

      # Confirma que sumiu do banco
      assert_raise Ecto.NoResultsError, fn ->
        Links.get_link!(link.id)
      end
    end
  end

  describe "increment_clicks/1" do
    test "incrementa o contador de cliques" do
      link = link_fixture()
      assert link.clicks == 0

      Links.increment_clicks(link)

      # Recarrega do banco pra ver o valor atualizado
      updated = Links.get_link!(link.id)
      assert updated.clicks == 1
    end

    test "incrementa múltiplas vezes" do
      link = link_fixture()

      Links.increment_clicks(link)
      Links.increment_clicks(link)
      Links.increment_clicks(link)

      updated = Links.get_link!(link.id)
      assert updated.clicks == 3
    end
  end

  describe "change_link/1" do
    test "retorna um changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Links.change_link(link)
    end
  end
end
