defmodule ExLinkWeb.Router do
  use ExLinkWeb, :router

  import ExLinkWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExLinkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :rate_limit_auth do
    plug ExLinkWeb.Plugs.RateLimit, max_requests: 10, interval_ms: 60_000
  end

  pipeline :rate_limit_redirect do
    plug ExLinkWeb.Plugs.RateLimit, max_requests: 60, interval_ms: 60_000
  end

  # ── Google OAuth ──────────────────────────────────────────
  scope "/auth", ExLinkWeb do
    pipe_through [:browser, :rate_limit_auth]

    get "/:provider", OAuthController, :request
    get "/:provider/callback", OAuthController, :callback
  end

  # ── Auth (registro, login, etc) — ANTES do catch-all ──────
  scope "/", ExLinkWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{ExLinkWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  # ── Rotas protegidas (precisa estar logado) ───────────────
  scope "/", ExLinkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated,
      on_mount: [{ExLinkWeb.UserAuth, :require_authenticated}] do
      live "/", LinkLive.Index, :index
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # ── Redirect público (catch-all — DEVE ser a última rota) ─
  scope "/", ExLinkWeb do
    pipe_through [:browser, :rate_limit_redirect]

    get "/:short_code", RedirectController, :show
  end

  # ── Dev tools ─────────────────────────────────────────────
  if Application.compile_env(:ex_link, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExLinkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
