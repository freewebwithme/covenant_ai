defmodule CovenantAI.Accounts.Changes.NotifyAccessRequestStatus do
  @moduledoc """
  Sends email notification when access request status changes
  to approved or rejected.
  """
  use Ash.Resource.Change

  alias CovenantAI.Emails.AccessRequestEmail
  alias CovenantAI.Mailer

  @impl true
  def change(changeset, _opts, _ctx) do
    Ash.Changeset.after_action(changeset, fn _changeset, result ->
      send_email(result)
      {:ok, result}
    end)
  end

  @spec send_email(Ash.Resource.record()) :: :ok
  def send_email(access_request) do
    access_request = Ash.load!(access_request, [:reviewed_by])

    case access_request.status do
      :approved -> send_approved_email(access_request)
      :rejected -> send_rejected_email(access_request)
      _ -> :ok
    end
  end

  defp send_approved_email(access_request) do
    access_request.email
    |> AccessRequestEmail.approved(access_request.hoa_name, access_request.reviewed_by.email)
    |> Mailer.deliver()
  end

  defp send_rejected_email(access_request) do
    access_request.email
    |> AccessRequestEmail.rejected(
      access_request.hoa_name,
      access_request.reviewed_by.email,
      access_request.internal_notes
    )
    |> Mailer.deliver()
  end
end
