defmodule ExLinkWeb.LinkLive.IndexTest do
  use ExLinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import ExLink.LinksFixtures

  # Registra e loga um usuário antes de cada teste
  setup :register_and_log_in_user

  describe "Index page" do
    test "mostra título da página", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "ExLink"
      assert html =~ "Encurte URLs em um clique"
    end

    test "mostra mensagem quando não há links", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Nenhum link criado ainda"
    end

    test "lista links do usuário logado", %{conn: conn, scope: scope} do
      link_fixture(%{scope: scope, original_url: "https://elixir-lang.org", short_code: "elixir"})

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "elixir"
      assert html =~ "https://elixir-lang.org"
    end

    test "não lista links de outro usuário", %{conn: conn} do
      # Cria link com outro usuário (scope padrão da fixture)
      link_fixture(%{original_url: "https://secreto.com", short_code: "secreto"})

      {:ok, _view, html} = live(conn, ~p"/")

      refute html =~ "https://secreto.com"
    end

    test "cria link via formulário", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", link: %{original_url: "https://phoenix.com"})
        |> render_submit()

      assert html =~ "Link criado!"
      assert html =~ "https://phoenix.com"
    end

    test "mostra erro de validação para URL inválida", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", link: %{original_url: "nao-sou-url"})
        |> render_submit()

      assert html =~ "must be a valid URL"
    end

    test "valida em tempo real enquanto digita", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", link: %{original_url: "abc"})
        |> render_change()

      assert html =~ "must be a valid URL"
    end

    test "deleta um link", %{conn: conn, scope: scope} do
      link = link_fixture(%{scope: scope, original_url: "https://deletar.com", short_code: "deleta"})

      {:ok, view, html} = live(conn, ~p"/")
      assert html =~ "https://deletar.com"

      view
      |> element(~s{button[phx-value-id="#{link.id}"][phx-click="delete_link"]})
      |> render_click()

      html = render(view)
      refute html =~ "https://deletar.com"
      assert html =~ "0 links"
    end
  end
end
