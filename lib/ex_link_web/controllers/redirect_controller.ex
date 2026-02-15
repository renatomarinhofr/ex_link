defmodule ExLinkWeb.RedirectController do
  use ExLinkWeb, :controller

  alias ExLink.Links

  # Quando alguém acessa /abc123:
  # 1. Busca o link pelo short_code
  # 2. Incrementa o contador de cliques
  # 3. Redireciona (HTTP 302) pra URL original
  def show(conn, %{"short_code" => short_code}) do
    case Links.get_link_by_short_code(short_code) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Link não encontrado")

      link ->
        Links.increment_clicks(link)

        conn
        |> redirect(external: link.original_url)
    end
  end
end
