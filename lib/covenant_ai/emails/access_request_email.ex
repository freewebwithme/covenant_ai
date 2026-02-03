defmodule CovenantAI.Emails.AccessRequestEmail do
  @moduledoc """
  Email templates for HOA community creation access requests.

  These emails are sent to board administrators requesting to
  create a new community on Covenant AI.
  """
  import Swoosh.Email

  @doc """
  Sends an email when a community creation request is approved.
  """
  @spec approved(String.t(), String.t(), String.t()) :: Swoosh.Email.t()
  def approved(requestor_email, community_name, approver_name) do
    new()
    |> to(requestor_email)
    |> from({"Covenant AI", "no-reply@covenantai.com"})
    |> subject("Community Creation Request Approved - #{community_name}")
    |> html_body("""
    <h2>Your community has been approved! 🎉</h2>
    <p>Hi there,</p>
    <p>
      Great news! Your request to create
      <strong>#{community_name}</strong> on Covenant AI has been
      approved by #{approver_name}.
    </p>
    <p>
      You can now log in and start setting up your HOA community
      dashboard, invite residents, and manage your community.
    </p>
    <p>
      <a href="#{app_url()}/login">Log in to Covenant AI</a>
    </p>
    <p>
      <strong>Next steps:</strong>
    </p>
    <ul>
      <li>Complete your community profile</li>
      <li>Upload governing documents (CC&Rs, Bylaws)</li>
      <li>Invite board members and residents</li>
      <li>Set up your community rules and policies</li>
    </ul>
    <p>
      If you need any help getting started, our support team is here
      for you.
    </p>
    <p>Best regards,<br>Covenant AI Team</p>
    """)
    |> text_body("""
    Your community has been approved!

    Hi there,

    Great news! Your request to create #{community_name} on
    Covenant AI has been approved by #{approver_name}.

    You can now log in and start setting up your HOA community
    dashboard, invite residents, and manage your community.

    Log in at: #{app_url()}/login

    Next steps:
    - Complete your community profile
    - Upload governing documents (CC&Rs, Bylaws)
    - Invite board members and residents
    - Set up your community rules and policies

    If you need any help getting started, our support team is here
    for you.

    Best regards,
    Covenant AI Team
    """)
  end

  @doc """
  Sends an email when a community creation request is rejected.
  """
  @spec rejected(String.t(), String.t(), String.t(), String.t() | nil) ::
          Swoosh.Email.t()
  def rejected(requestor_email, community_name, rejector_name, reason) do
    reason_text =
      if reason do
        """
        <p><strong>Reason for rejection:</strong></p>
        <p>#{reason}</p>
        """
      else
        ""
      end

    reason_plain = if reason, do: "\nReason: #{reason}\n", else: ""

    new()
    |> to(requestor_email)
    |> from({"Covenant AI", "no-reply@covenantai.com"})
    |> subject("Community Creation Request Update - #{community_name}")
    |> html_body("""
    <h2>Community Creation Request Update</h2>
    <p>Hi there,</p>
    <p>
      Thank you for your interest in creating
      <strong>#{community_name}</strong> on Covenant AI.
    </p>
    <p>
      After review by #{rejector_name}, we are unable to approve
      your request at this time.
    </p>
    #{reason_text}
    <p>
      If you have questions or would like to discuss this decision,
      please contact us at
      <a href="mailto:support@covenantai.com">
        support@covenantai.com
      </a>.
    </p>
    <p>
      We appreciate your understanding and hope to work with you in
      the future.
    </p>
    <p>Best regards,<br>Covenant AI Team</p>
    """)
    |> text_body("""
    Community Creation Request Update

    Hi there,

    Thank you for your interest in creating #{community_name} on
    Covenant AI.

    After review by #{rejector_name}, we are unable to approve your
    request at this time.
    #{reason_plain}
    If you have questions or would like to discuss this decision,
    please contact us at support@covenantai.com.

    We appreciate your understanding and hope to work with you in
    the future.

    Best regards,
    Covenant AI Team
    """)
  end

  defp app_url do
    CovenantAIWeb.Endpoint.url()
  end
end
