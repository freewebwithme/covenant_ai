defmodule CovenantAI.Repo do
  use AshPostgres.Repo,
    otp_app: :covenant_ai,
    adapter: Ecto.Adapters.Postgres

  @impl true
  def installed_extensions do
    ["ash-functions", "citext"]
  end

  # Don't open unnecessary transactions
  # will default to `false` in 4.0
  @impl true
  def prefer_transaction? do
    false
  end

  @impl true
  def min_pg_version do
    %Version{major: 16, minor: 4, patch: 0}
  end
end
