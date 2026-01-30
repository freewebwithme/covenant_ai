defmodule CovenantAI.Communities.Document do
  @moduledoc """
  Represents community documents (bylaws, CC&Rs, policies, etc)
  """
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    domain: CovenantAI.Communities,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "community_documents"
    repo CovenantAI.Repo
  end

  attributes do
    uuid_v7_primary_key :id
    create_timestamp :created_at

    attribute :document_type, :atom do
      constraints one_of: [
                    :bylaws,
                    # Covenants, Conditions & Restrictions
                    :ccr,
                    :policy,
                    :other
                  ]

      allow_nil? false
    end

    attribute :title, :string do
      allow_nil? false
      constraints max_length: 200
    end

    attribute :description, :string do
      constraints max_length: 500
    end

    attribute :file_path, :string, allow_nil?: false
    attribute :file_name, :string, allow_nil?: false, constraints: [max_length: 255]
  end

  relationships do
    belongs_to :community, CovenantAI.Communities.Community, allow_nil?: false

    belongs_to :uploaded_by, CovenantAI.Accounts.User do
      allow_nil? false
      description "User who uploaded this document"
    end
  end

  actions do
    defaults [:read]

    create :upload do
      accept [:document_type, :title, :description, :file_path, :file_name]

      argument :community_id, :uuid, allow_nil?: false
      argument :uploaded_by_id, :uuid, allow_nil?: false

      change relate_actor(:uplaoded_by)
      change manage_relationship(:community_id, :community, type: :append)
    end
  end

  policies do
    # Anyone in the community can read documents
    policy action_type(:read) do
      authorize_if relates_to_actor_via([:community, :residents])
    end

    policy action_type([:create, :update]) do
      authorize_if actor_attribute_equals(:role, :board_member)
      authorize_if actor_attribute_equals(:role, :super_admin)
    end
  end
end
