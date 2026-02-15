defmodule ExLinkWeb.LinkLive.IndexTest do
  use ExLinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import ExLink.LinksFixtures

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

    test "lista links existentes", %{conn: conn} do
      link_fixture(%{original_url: "https://elixir-lang.org", short_code: "elixir"})

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "elixir"
      assert html =~ "https://elixir-lang.org"
    end

    test "cria link via formulário", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", link: %{original_url: "https://phoenix.com"})
        |> render_submit()

      # "Link criado!" está no template da LiveView (div de sucesso)
      # "Link criado com sucesso!" é flash :info e fica no layout (fora do render)
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

    test "deleta um link", %{conn: conn} do
      link = link_fixture(%{original_url: "https://deletar.com", short_code: "deleta"})

      {:ok, view, html} = live(conn, ~p"/")

      # Confirma que o link aparece antes
      assert html =~ "https://deletar.com"

      # Clica no botão de deletar
      view
      |> element(~s{button[phx-value-id="#{link.id}"][phx-click="delete_link"]})
      |> render_click()

      # Após deletar, re-renderiza e o link sumiu
      html = render(view)
      refute html =~ "https://deletar.com"
      assert html =~ "0 links"
    end
  end
end
