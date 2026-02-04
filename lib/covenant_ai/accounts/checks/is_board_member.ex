defmodule CovenantAI.Accounts.Checks.IsBoardMember do
  use Ash.Policy.SimpleCheck

  @impl true
  def describe(_opts) do
    "actor must have board_member role"
  end

  @impl true
  def match?(_actor = %{role: role}, _ctx, _opts) when role in [:board_admin, :board_member],
    do: true

  def match?(_actor, _ctx, _opts), do: false
end
