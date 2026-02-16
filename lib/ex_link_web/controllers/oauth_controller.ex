defmodule ExLinkWeb.OAuthController do
  @moduledoc """
  Handles Google OAuth callbacks.
  Ueberauth does the OAuth dance (redirect → Google → callback).
  """
  use ExLinkWeb, :controller

  alias ExLink.Accounts
  alias ExLinkWeb.UserAuth

  # Ueberauth injeta :ueberauth_auth ou :ueberauth_failure nos assigns
  plug Ueberauth

  @doc """
  Request phase: Ueberauth intercepta no plug e redireciona ao provider.
  Esta função existe apenas como fallback.
  """
  def request(conn, _params), do: conn

  @doc """
  Callback chamado pelo Google após autenticação.
  Ueberauth já processou o token e preencheu conn.assigns.
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_attrs = %{
      email: auth.info.email,
      name: auth.info.name,
      avatar_url: auth.info.image,
      google_uid: to_string(auth.uid)
    }

    case Accounts.find_or_create_google_user(user_attrs) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user, %{"remember_me" => "true"})

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Erro ao autenticar com Google. Tente novamente.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _failure}} = conn, _params) do
    conn
    |> put_flash(:error, "Autenticação com Google falhou. Tente novamente.")
    |> redirect(to: ~p"/users/log-in")
  end
end
