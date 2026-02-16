defmodule ExLinkWeb.UserLive.Login do
  use ExLinkWeb, :live_view

  alias ExLink.Accounts

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950 flex items-center justify-center px-6">
      <div class="w-full max-w-md">
        <%!-- Logo --%>
        <div class="text-center mb-10">
          <a href="/" class="text-4xl font-extrabold tracking-tight">
            <span class="text-emerald-400">⚡</span> ExLink
          </a>
        </div>

        <%!-- Card --%>
        <div class="bg-zinc-800/50 border border-zinc-700/50 rounded-2xl p-8">
          <h2 class="text-2xl font-bold text-white text-center mb-2">Entrar</h2>
          <p class="text-zinc-400 text-sm text-center mb-8">
            <%= if @current_scope do %>
              Reautentique para ações sensíveis.
            <% else %>
              Não tem conta?
              <.link navigate={~p"/users/register"} class="text-emerald-400 hover:text-emerald-300 font-semibold">
                Criar conta
              </.link>
            <% end %>
          </p>

          <%!-- Google OAuth --%>
          <a
            href={~p"/auth/google"}
            class="w-full flex items-center justify-center gap-3 bg-white hover:bg-zinc-100 text-zinc-800 font-semibold rounded-xl py-3 px-4 text-sm transition-all duration-200"
          >
            <svg class="h-5 w-5" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Entrar com Google
          </a>

          <div class="flex items-center gap-4 my-6">
            <div class="flex-1 h-px bg-zinc-700"></div>
            <span class="text-zinc-500 text-xs">ou com email</span>
            <div class="flex-1 h-px bg-zinc-700"></div>
          </div>

          <%!-- Login com email mágico --%>
          <.form
            :let={f}
            for={@form}
            id="login_form_magic"
            action={~p"/users/log-in"}
            phx-submit="submit_magic"
          >
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Email</label>
                <input
                  type="email"
                  name={f[:email].name}
                  value={f[:email].value}
                  readonly={!!@current_scope}
                  autocomplete="email"
                  required
                  phx-mounted={JS.focus()}
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="seu@email.com"
                />
              </div>
              <button
                type="submit"
                class="w-full bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
              >
                Entrar com link mágico →
              </button>
            </div>
          </.form>

          <div class="flex items-center gap-4 my-6">
            <div class="flex-1 h-px bg-zinc-700"></div>
            <span class="text-zinc-500 text-xs">ou com senha</span>
            <div class="flex-1 h-px bg-zinc-700"></div>
          </div>

          <%!-- Login com senha --%>
          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Email</label>
                <input
                  type="email"
                  name={f[:email].name}
                  value={f[:email].value}
                  readonly={!!@current_scope}
                  autocomplete="email"
                  required
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="seu@email.com"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Senha</label>
                <input
                  type="password"
                  name={@form[:password].name}
                  value={@form[:password].value}
                  autocomplete="current-password"
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="••••••••"
                />
              </div>
              <button
                type="submit"
                name={@form[:remember_me].name}
                value="true"
                class="w-full bg-zinc-700 hover:bg-zinc-600 text-white font-semibold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
              >
                Entrar com senha
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>

    <Layouts.flash_group flash={@flash} />
    """
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info = "Se o email estiver cadastrado, você receberá um link de acesso em instantes."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end
end
