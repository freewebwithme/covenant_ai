defmodule CovenantAi.Repo do
  use Ecto.Repo,
    otp_app: :covenant_ai,
    adapter: Ecto.Adapters.Postgres
end
