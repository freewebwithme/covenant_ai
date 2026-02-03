defmodule CovenantAI.Accounts.AccessRequest do
  @moduledoc """
  Represents a request from a potential Board Admin to join Covenant AI.

  Flow:
  1. Board Admin submits request via public form
  2. Super Admin reviews and approves/rejects
  3. On approval, invitation is sent automatically
  """

  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    domain: CovenantAI.Accounts,
    otp_app: :covenant_ai

  postgres do
    table "access_requests"
    repo CovenantAI.Repo
  end

  identities do
    identity :unique_email, [:email] do
      message "This email has already submitted a request. Please contact support."
    end
  end

  attributes do
    uuid_v7_primary_key :id
    create_timestamp :created_at

    attribute :full_name, :string, allow_nil?: false
    attribute :email, :string, allow_nil?: false
    attribute :phone, :string, allow_nil?: false

    # HOA information
    attribute :hoa_name, :string, allow_nil?: false
    attribute :hoa_address, CovenantAI.Communities.Address, allow_nil?: false
    attribute :estimated_units, :integer
    attribute :website, :string

    attribute :role_in_hoa, :string, allow_nil?: false

    attribute :how_found_us, :string

    attribute :status, :atom do
      constraints one_of: [:pending, :approved, :rejected]
      default :pending
      allow_nil? false
    end

    attribute :reviewed_at, :utc_datetime_usec
    attribute :internal_notes, :string
  end

  relationships do
    belongs_to :reviewed_by, CovenantAI.Accounts.User do
      description "Covenant AI employee who reviewed this request"
    end
  end

  actions do
    create :create do
      accept [
        :full_name,
        :email,
        :phone,
        :hoa_name,
        :hoa_address,
        :estimated_units,
        :website,
        :role_in_hoa,
        :how_found_us
      ]
    end

    read :list do
      prepare build(sort: [created_at: :desc])
    end

    read :list_pending do
      filter expr(status == :pending)
      prepare build(sort: [created_at: :asc])
    end

    update :approve do
      require_atomic? false
      change set_attribute(:status, :approved)
      change set_attribute(:reviewed_at, &DateTime.utc_now/0)
      change relate_actor(:reviewed_by)

      change CovenantAI.Accounts.Changes.CreateCommunityFromRequest
      change CovenantAI.Accounts.Changes.NotifyAccessRequestStatus
    end

    update :reject do
      accept [:internal_notes]
      require_atomic? false

      change set_attribute(:status, :rejected)
      change set_attribute(:reviewed_at, &DateTime.utc_now/0)
      change relate_actor(:reviewed_by)

      change CovenantAI.Accounts.Changes.CreateCommunityFromRequest
      change CovenantAI.Accounts.Changes.NotifyAccessRequestStatus
    end
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/) do
      message "must be a valid email format"
    end

    validate numericality(:estimated_units, greater_than: 0) do
      message "must be a positive number"
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :super_admin) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type([:read, :update]) do
      authorize_if actor_attribute_equals(:role, :super_admin)
    end
  end
end
