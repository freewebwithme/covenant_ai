defmodule CovenantAI.Accounts.Checks.IsSuperAdmin do
  use Ash.Policy.SimpleCheck

  @impl true
  def describe(_opts) do
    "actor must have super_admin role"
  end

  @impl true
  def match?(_actor = %{role: :super_admin}, _ctx, _opts), do: true
  def match?(_actor, _ctx, _opts), do: false
end
