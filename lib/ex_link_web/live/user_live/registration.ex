defmodule ExLinkWeb.UserLive.Registration do
  use ExLinkWeb, :live_view

  alias ExLink.Accounts
  alias ExLink.Accounts.User

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: ExLinkWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
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
          <h2 class="text-2xl font-bold text-white text-center mb-2">Criar conta</h2>
          <p class="text-zinc-400 text-sm text-center mb-8">
            Já tem conta?
            <.link navigate={~p"/users/log-in"} class="text-emerald-400 hover:text-emerald-300 font-semibold">
              Entrar
            </.link>
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
            Criar conta com Google
          </a>

          <div class="flex items-center gap-4 my-6">
            <div class="flex-1 h-px bg-zinc-700"></div>
            <span class="text-zinc-500 text-xs">ou com email</span>
            <div class="flex-1 h-px bg-zinc-700"></div>
          </div>

          <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Email</label>
                <input
                  type="email"
                  name={@form[:email].name}
                  value={@form[:email].value}
                  autocomplete="username"
                  required
                  phx-mounted={JS.focus()}
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="seu@email.com"
                />
                <p
                  :for={msg <- Enum.map(@form[:email].errors, &translate_error/1)}
                  class="mt-2 text-red-400 text-xs"
                >
                  {msg}
                </p>
              </div>

              <button
                type="submit"
                phx-disable-with="Criando conta..."
                class="w-full bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-3 px-4 text-sm transition-all duration-200 cursor-pointer"
              >
                Criar conta →
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
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(:info, "Email enviado para #{user.email}. Acesse para confirmar sua conta.")
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
