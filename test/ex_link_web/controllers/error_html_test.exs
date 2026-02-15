defmodule ExLinkWeb.ErrorHTMLTest do
  use ExLinkWeb.ConnCase, async: true

  import Phoenix.Template, only: [render_to_string: 4]

  test "renders 404.html with custom page" do
    html = render_to_string(ExLinkWeb.ErrorHTML, "404", "html", [])

    assert html =~ "404"
    assert html =~ "não encontrado"
    assert html =~ "Voltar para o início"
  end

  test "renders 500.html" do
    assert render_to_string(ExLinkWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
