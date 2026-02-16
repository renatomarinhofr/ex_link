defmodule ExLinkWeb.Plugs.RateLimit do
  @moduledoc """
  Plug de rate limiting usando Hammer.
  Limita requests por IP para evitar abuso.

  ## Uso no router:

      plug ExLinkWeb.Plugs.RateLimit, max_requests: 5, interval_ms: 60_000
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    %{
      max_requests: Keyword.get(opts, :max_requests, 10),
      interval_ms: Keyword.get(opts, :interval_ms, 60_000)
    }
  end

  def call(conn, %{max_requests: max, interval_ms: interval}) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    bucket = "rate_limit:#{conn.request_path}:#{ip}"

    case Hammer.check_rate(bucket, interval, max) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Muitas requisições. Tente novamente em breve."})
        |> halt()
    end
  end
end
