defmodule CovenantAI.Accounts.Changes.CreateCommunityFromRequest do
  @moduledoc """
  Creates a new Community when an `AccessRequest` is approved.
  if `AccessRequest` is rejected, we create a new Community with :pending status.

  This runs inside the transaction, so if community creation fails,
  the entire approval is rolled back.
  """

  use Ash.Resource.Change

  alias CovenantAI.Communities.Community

  @impl true
  def change(changeset, _opts, _ctx) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      request = changeset.data

      Community
      |> Ash.Changeset.for_create(:create, %{
        name: request.hoa_name,
        address: request.address,
        contact_email: request.email,
        contact_phone: request.phone,
        status: if(request.status == :approved, do: :active, else: :pending)
      })
      |> Ash.create!()

      changeset
    end)
  end
end
