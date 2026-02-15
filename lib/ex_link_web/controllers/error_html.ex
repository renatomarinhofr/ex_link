defmodule ExLinkWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.
  """
  use ExLinkWeb, :html

  embed_templates "error_html/*"

  # Fallback para templates não customizados (ex: 500)
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
