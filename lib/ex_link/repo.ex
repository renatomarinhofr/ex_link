defmodule ExLink.Repo do
  use Ecto.Repo,
    otp_app: :ex_link,
    adapter: Ecto.Adapters.Postgres
end
