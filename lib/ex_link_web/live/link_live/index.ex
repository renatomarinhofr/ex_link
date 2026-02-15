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

    {:ok, socket}
  end

  @impl true
  def handle_info({:link_updated, _link_id}, socket) do
    {:noreply, assign(socket, :links, Links.list_links())}
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

          <%!-- Form com HTML puro pra controle total do estilo --%>
          <form phx-submit="create_link" class="w-full">
            <div class="flex flex-col sm:flex-row gap-3">
              <input
                type="text"
                name="link[original_url]"
                value={@form[:original_url].value}
                placeholder="Cole sua URL aqui... https://exemplo.com/minha-url-longa"
                autocomplete="off"
                class="flex-1 bg-zinc-800 border border-zinc-700 text-white placeholder-zinc-500 rounded-xl py-4 px-5 text-base focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
              />
              <button
                type="submit"
                phx-disable-with="Criando..."
                class="bg-emerald-500 hover:bg-emerald-400 text-zinc-950 font-bold rounded-xl py-4 px-8 text-base transition-all duration-200 cursor-pointer whitespace-nowrap"
              >
                Encurtar →
              </button>
            </div>

            <%!-- Erro de validação --%>
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

                <div class="bg-zinc-900 rounded-lg px-3 py-1.5 text-center shrink-0">
                  <p class="text-white font-bold text-lg leading-none">{link.clicks}</p>
                  <p class="text-zinc-500 text-xs mt-0.5">cliques</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

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

end
