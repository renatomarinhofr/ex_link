defmodule ExLinkWeb.PageController do
  use ExLinkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
