defmodule ExLinkWeb.UserLive.Confirmation do
  use ExLinkWeb, :live_view

  alias ExLink.Accounts

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "user")

      {:ok, assign(socket, user: user, form: form, trigger_submit: false),
       temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "Link de acesso inválido ou expirado.")
       |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950 flex items-center justify-center px-6">
      <div class="w-full max-w-md">
        <div class="text-center mb-10">
          <a href="/" class="text-4xl font-extrabold tracking-tight">
            <span class="text-emerald-400">⚡</span> ExLink
          </a>
        </div>

        <div class="bg-zinc-800/50 border border-zinc-700/50 rounded-2xl p-8">
          <h2 class="text-2xl font-bold text-white text-center mb-2">
            Bem-vindo!
          </h2>
          <p class="text-zinc-400 text-sm text-center mb-8">
            {@user.email}
          </p>

          <%!-- Primeiro acesso (confirmar conta) --%>
          <.form
            :if={!@user.confirmed_at}
            for={@form}
            id="confirmation_form"
            phx-mounted={JS.focus_first()}
            phx-submit="submit"
            action={~p"/users/log-in?_action=confirmed"}
            phx-trigger-action={@trigger_submit}
          >
            <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
            <div class="space-y-3">
              <button
                type="submit"
                name={@form[:remember_me].name}
                value="true"
                phx-disable-with="Confirmando..."
                class="w-full bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
              >
                Confirmar e manter logado
              </button>
              <button
                type="submit"
                phx-disable-with="Confirmando..."
                class="w-full bg-zinc-700 hover:bg-zinc-600 text-white font-semibold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
              >
                Confirmar (só desta vez)
              </button>
            </div>
          </.form>

          <%!-- Login via magic link (conta já confirmada) --%>
          <.form
            :if={@user.confirmed_at}
            for={@form}
            id="login_form"
            phx-submit="submit"
            phx-mounted={JS.focus_first()}
            action={~p"/users/log-in"}
            phx-trigger-action={@trigger_submit}
          >
            <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
            <div class="space-y-3">
              <%= if @current_scope do %>
                <button
                  type="submit"
                  phx-disable-with="Entrando..."
                  class="w-full bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
                >
                  Entrar
                </button>
              <% else %>
                <button
                  type="submit"
                  name={@form[:remember_me].name}
                  value="true"
                  phx-disable-with="Entrando..."
                  class="w-full bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
                >
                  Manter logado
                </button>
                <button
                  type="submit"
                  phx-disable-with="Entrando..."
                  class="w-full bg-zinc-700 hover:bg-zinc-600 text-white font-semibold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
                >
                  Entrar só desta vez
                </button>
              <% end %>
            </div>
          </.form>

          <p :if={!@user.confirmed_at} class="text-zinc-500 text-xs text-center mt-6">
            Dica: Você pode definir uma senha nas configurações da conta.
          </p>
        </div>
      </div>
    </div>

    <Layouts.flash_group flash={@flash} />
    """
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end
