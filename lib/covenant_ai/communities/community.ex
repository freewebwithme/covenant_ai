defmodule CovenantAI.Communities.Community do
  @moduledoc """
  Represents a Homeowners Association (HOA) community.

  A Community contains multiple units, residents, and has its own set
  of rules and bylaws that govern the association.
  """
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    domain: CovenantAI.Communities,
    otp_app: :covenant_ai

  postgres do
    table "communities"
    repo CovenantAI.Repo
  end

  attributes do
    uuid_v7_primary_key :id
    create_timestamp :created_at

    attribute :name, :string do
      allow_nil? false
      description "Name of the HOA community"
    end

    attribute :address, CovenantAI.Communities.Address do
      allow_nil? false
      description "Physical address of the community"
    end

    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :pending]
      default :inactive
      allow_nil? false
    end

    attribute :contact_email, :string
    attribute :contact_phone, :string
  end

  relationships do
    has_many :residents, CovenantAI.Accounts.User do
      filter expr(role == :resident)
    end

    has_many :board_members, CovenantAI.Accounts.User do
      filter expr(role in [:board_member, :board_admin])
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :name,
        :address,
        :contact_email,
        :contact_phone,
        :status
      ]
    end

    update :update do
      primary? true

      accept [
        :name,
        :address,
        :contact_email,
        :contact_phone,
        :status
      ]
    end

    update :update_contact do
      accept [:contact_email, :contact_phone]
    end
  end

  policies do
    bypass action(:update_contact) do
      authorize_if actor_attribute_equals(:role, :board_admin)
    end

    policy action_type([:create, :update]) do
      authorize_if actor_attribute_equals(:role, :super_admin)
    end

    policy action_type([:read]) do
      authorize_if actor_present()
    end
  end
end
