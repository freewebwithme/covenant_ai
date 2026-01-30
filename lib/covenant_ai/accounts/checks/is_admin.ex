defmodule CovenantAI.Accounts.Checks.IsAdmin do
  @moduledoc """
  Check if actor is :board_admin or :super_admin
  """
  use Ash.Policy.SimpleCheck

  @admin_roles [:board_admin, :super_admin]

  @impl true
  def describe(_opts) do
    "actor must have admin role"
  end

  @impl true
  def match?(_actor = %{role: role}, _context, _opts) do
    role in @admin_roles
  end
end
