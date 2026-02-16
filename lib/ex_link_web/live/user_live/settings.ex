defmodule ExLinkWeb.UserLive.Settings do
  use ExLinkWeb, :live_view

  on_mount {ExLinkWeb.UserAuth, :require_sudo_mode}

  alias ExLink.Accounts

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email alterado com sucesso.")

        {:error, _} ->
          put_flash(socket, :error, "Link de alteração de email inválido ou expirado.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950">
      <div class="max-w-2xl mx-auto px-6 py-12">
        <%!-- Header com voltar --%>
        <div class="flex items-center justify-between mb-10">
          <.link navigate={~p"/"} class="flex items-center gap-2 text-zinc-400 hover:text-white transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
            </svg>
            Voltar
          </.link>
          <.link
            href={~p"/users/log-out"}
            method="delete"
            class="text-zinc-500 hover:text-red-400 text-sm transition-colors"
          >
            Sair da conta
          </.link>
        </div>

        <h1 class="text-3xl font-extrabold text-white mb-2">Configurações</h1>
        <p class="text-zinc-400 mb-10">Gerencie seu email e senha.</p>

        <%!-- Email --%>
        <div class="bg-zinc-800/50 border border-zinc-700/50 rounded-2xl p-6 mb-6">
          <h2 class="text-lg font-bold text-white mb-4">Alterar email</h2>
          <p class="text-zinc-500 text-sm mb-4">Email atual: <span class="text-zinc-300">{@current_email}</span></p>

          <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Novo email</label>
                <input
                  type="email"
                  name={@email_form[:email].name}
                  value={@email_form[:email].value}
                  autocomplete="username"
                  required
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="novo@email.com"
                />
                <p
                  :for={msg <- Enum.map(@email_form[:email].errors, &translate_error/1)}
                  class="mt-2 text-red-400 text-xs"
                >
                  {msg}
                </p>
              </div>
              <button
                type="submit"
                phx-disable-with="Salvando..."
                class="bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-2.5 px-6 text-sm transition-all duration-200 cursor-pointer"
              >
                Alterar email
              </button>
            </div>
          </.form>
        </div>

        <%!-- Senha --%>
        <div class="bg-zinc-800/50 border border-zinc-700/50 rounded-2xl p-6">
          <h2 class="text-lg font-bold text-white mb-4">Alterar senha</h2>

          <.form
            for={@password_form}
            id="password_form"
            action={~p"/users/update-password"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <input
              name={@password_form[:email].name}
              type="hidden"
              id="hidden_user_email"
              autocomplete="username"
              value={@current_email}
            />
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Nova senha</label>
                <input
                  type="password"
                  name={@password_form[:password].name}
                  value={@password_form[:password].value}
                  autocomplete="new-password"
                  required
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="••••••••"
                />
                <p
                  :for={msg <- Enum.map(@password_form[:password].errors, &translate_error/1)}
                  class="mt-2 text-red-400 text-xs"
                >
                  {msg}
                </p>
              </div>
              <div>
                <label class="block text-sm font-medium text-zinc-300 mb-2">Confirmar nova senha</label>
                <input
                  type="password"
                  name={@password_form[:password_confirmation].name}
                  value={@password_form[:password_confirmation].value}
                  autocomplete="new-password"
                  class="w-full bg-zinc-900 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-3 px-4 text-sm focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
                  placeholder="••••••••"
                />
                <p
                  :for={msg <- Enum.map(@password_form[:password_confirmation].errors, &translate_error/1)}
                  class="mt-2 text-red-400 text-xs"
                >
                  {msg}
                </p>
              </div>
              <button
                type="submit"
                phx-disable-with="Salvando..."
                class="bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-2.5 px-6 text-sm transition-all duration-200 cursor-pointer"
              >
                Alterar senha
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
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        {:noreply, put_flash(socket, :info, "Link de confirmação enviado para o novo email.")}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
