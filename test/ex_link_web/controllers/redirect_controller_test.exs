defmodule ExLinkWeb.RedirectControllerTest do
  use ExLinkWeb.ConnCase

  import ExLink.LinksFixtures

  describe "GET /:short_code" do
    test "redireciona para a URL original", %{conn: conn} do
      link = link_fixture(%{original_url: "https://elixir-lang.org", short_code: "elixir"})

      conn = get(conn, ~p"/#{link.short_code}")

      assert redirected_to(conn) == "https://elixir-lang.org"
    end

    test "incrementa cliques ao redirecionar", %{conn: conn} do
      scope = scope_fixture()
      link = link_fixture(%{scope: scope, short_code: "clicks1"})
      assert link.clicks == 0

      get(conn, ~p"/#{link.short_code}")

      updated = ExLink.Links.get_link!(scope, link.id)
      assert updated.clicks == 1
    end

    test "retorna 404 para short_code inexistente", %{conn: conn} do
      conn = get(conn, ~p"/naoexiste")

      assert conn.status == 404
      assert conn.resp_body =~ "não encontrado"
    end
  end
end
