defmodule ExLinkWeb.LinkLive.Index do
  use ExLinkWeb, :live_view

  alias ExLink.Links

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Links.subscribe()

    socket =
      socket
      |> assign(:links, Links.list_links())
      |> assign(:form, to_form(Links.change_link(%Links.Link{})))
      |> assign(:copied_id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_info({:link_updated, _link_id}, socket) do
    {:noreply, assign(socket, :links, Links.list_links())}
  end

  # Limpa o feedback "Copiado!" depois de 2 segundos
  @impl true
  def handle_info(:clear_copied, socket) do
    {:noreply, assign(socket, :copied_id, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950 text-white">
      <%!-- Hero --%>
      <div class="px-6 pt-20 pb-16">
        <div class="max-w-3xl mx-auto text-center">
          <h1 class="text-5xl font-extrabold tracking-tight mb-3">
            <span class="text-emerald-400">⚡</span> ExLink
          </h1>
          <p class="text-zinc-400 text-lg mb-10">
            Encurte URLs em um clique. Acompanhe cliques em tempo real.
          </p>

          <%!-- Form com validação em tempo real (phx-change) --%>
          <form phx-submit="create_link" phx-change="validate" class="w-full">
            <div class="flex flex-col sm:flex-row gap-3">
              <input
                type="text"
                name="link[original_url]"
                value={@form[:original_url].value}
                placeholder="Cole sua URL aqui... https://exemplo.com/minha-url-longa"
                autocomplete="off"
                phx-debounce="300"
                class={[
                  "flex-1 bg-zinc-800 border text-white placeholder-zinc-500 rounded-xl py-4 px-5 text-base focus:outline-none focus:ring-2 transition-colors",
                  if(@form[:original_url].errors != [],
                    do: "border-red-500 focus:border-red-500 focus:ring-red-500/20",
                    else: "border-zinc-700 focus:border-emerald-500 focus:ring-emerald-500/20"
                  )
                ]}
              />
              <button
                type="submit"
                phx-disable-with="Criando..."
                class="bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-4 px-8 text-base transition-all duration-200 cursor-pointer whitespace-nowrap"
              >
                Encurtar →
              </button>
            </div>

            <%!-- Erro de validação em tempo real --%>
            <p
              :for={msg <- Enum.map(@form[:original_url].errors, &translate_error/1)}
              class="mt-3 text-red-400 text-sm text-left"
            >
              {msg}
            </p>
          </form>

          <%!-- Link criado com sucesso --%>
          <div
            :if={@flash["short_url"]}
            class="mt-6 bg-emerald-500/10 border border-emerald-500/30 rounded-xl p-4 flex items-center justify-between gap-4"
          >
            <div class="flex items-center gap-3">
              <span class="text-emerald-400 text-xl">✓</span>
              <span class="text-zinc-300 text-sm">Link criado!</span>
            </div>
            <a
              href={@flash["short_url"]}
              target="_blank"
              class="font-mono text-emerald-400 hover:text-emerald-300 font-semibold text-sm underline underline-offset-4"
            >
              {@flash["short_url"]}
            </a>
          </div>
        </div>
      </div>

      <%!-- Lista de Links --%>
      <div class="px-6 pb-20">
        <div class="max-w-3xl mx-auto">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-bold">Seus links</h2>
            <span class="text-zinc-500 text-sm">{length(@links)} links</span>
          </div>

          <p :if={@links == []} class="text-zinc-600 text-center py-16">
            Nenhum link criado ainda. Cole uma URL acima para começar.
          </p>

          <div :if={@links != []} class="space-y-2">
            <div
              :for={link <- @links}
              class="bg-zinc-800/50 hover:bg-zinc-800 border border-zinc-800 hover:border-zinc-700 rounded-xl p-5 transition-all duration-200"
            >
              <div class="flex items-center justify-between gap-4">
                <%!-- URLs --%>
                <div class="min-w-0 flex-1 space-y-1">
                  <a
                    href={~p"/#{link.short_code}"}
                    target="_blank"
                    class="font-mono text-emerald-400 hover:text-emerald-300 font-semibold text-sm transition-colors"
                  >
                    /{link.short_code} ↗
                  </a>
                  <p class="text-zinc-500 text-sm truncate">
                    {link.original_url}
                  </p>
                </div>

                <%!-- Actions --%>
                <div class="flex items-center gap-3 shrink-0">
                  <%!-- Cliques --%>
                  <div class="bg-zinc-900 rounded-lg px-3 py-1.5 text-center">
                    <p class="text-white font-bold text-lg leading-none">{link.clicks}</p>
                    <p class="text-zinc-500 text-xs mt-0.5">cliques</p>
                  </div>

                  <%!-- Copiar --%>
                  <button
                    phx-click="copy_link"
                    phx-value-short-code={link.short_code}
                    phx-value-id={link.id}
                    class="p-2 rounded-lg bg-zinc-900 hover:bg-zinc-700 text-zinc-400 hover:text-white transition-colors cursor-pointer"
                    title="Copiar link"
                  >
                    <%= if @copied_id == link.id do %>
                      <span class="text-emerald-400 text-xs font-semibold px-1">✓</span>
                    <% else %>
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M8 3a1 1 0 011-1h2a1 1 0 110 2H9a1 1 0 01-1-1z" />
                        <path d="M6 3a2 2 0 00-2 2v11a2 2 0 002 2h8a2 2 0 002-2V5a2 2 0 00-2-2 3 3 0 01-3 3H9a3 3 0 01-3-3z" />
                      </svg>
                    <% end %>
                  </button>

                  <%!-- Deletar --%>
                  <button
                    phx-click="delete_link"
                    phx-value-id={link.id}
                    data-confirm="Tem certeza que deseja deletar este link?"
                    class="p-2 rounded-lg bg-zinc-900 hover:bg-red-500/20 text-zinc-400 hover:text-red-400 transition-colors cursor-pointer"
                    title="Deletar link"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ── Events ──────────────────────────────────────────────

  # Validação em tempo real enquanto digita
  # phx-change envia a cada keystroke (com debounce de 300ms)
  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset =
      %Links.Link{}
      |> Links.change_link(link_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  # Criar link
  @impl true
  def handle_event("create_link", %{"link" => link_params}, socket) do
    case Links.create_link(link_params) do
      {:ok, link} ->
        short_url = url(~p"/#{link.short_code}")

        socket =
          socket
          |> assign(:links, Links.list_links())
          |> assign(:form, to_form(Links.change_link(%Links.Link{})))
          |> put_flash(:info, "Link criado com sucesso!")
          |> put_flash(:short_url, short_url)

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :form, to_form(Map.put(changeset, :action, :validate)))
        {:noreply, socket}
    end
  end

  # Copiar link pro clipboard (via JS hook)
  @impl true
  def handle_event("copy_link", %{"short-code" => short_code, "id" => id}, socket) do
    short_url = url(~p"/#{short_code}")

    # Envia comando JS pro browser copiar pro clipboard
    socket =
      socket
      |> push_event("clipboard:copy", %{text: short_url})
      |> assign(:copied_id, id)

    # Agenda limpar o feedback depois de 2s
    Process.send_after(self(), :clear_copied, 2000)

    {:noreply, socket}
  end

  # Deletar link
  @impl true
  def handle_event("delete_link", %{"id" => id}, socket) do
    link = Links.get_link!(id)
    {:ok, _} = Links.delete_link(link)

    socket =
      socket
      |> assign(:links, Links.list_links())
      |> put_flash(:info, "Link deletado!")

    {:noreply, socket}
  end
end
