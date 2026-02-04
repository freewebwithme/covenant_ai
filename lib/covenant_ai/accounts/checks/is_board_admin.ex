defmodule CovenantAI.Accounts.Checks.IsBoardAdmin do
  @moduledoc """
  Check if actor is :board_admin or :super_admin
  """
  use Ash.Policy.SimpleCheck

  @impl true
  def describe(_opts) do
    "actor must have board_admin role"
  end

  @impl true
  def match?(_actor = %{role: :board_admin}, _ctx, _opts), do: true
  def match?(_actor, _ctx, _opts), do: false
end
