defmodule CovenantAI.Accounts.User do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    domain: CovenantAI.Accounts,
    extensions: [AshAuthentication],
    otp_app: :covenant_ai

  # multitenancy do
  #   strategy :attribute
  #   attribute :org_id
  # end

  defmodule Role do
    use Ash.Type.Enum,
      values: [:resident, :board_member, :board_admin, :super_admin]
  end

  postgres do
    table "users"
    repo CovenantAI.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  attributes do
    uuid_v7_primary_key :id
    create_timestamp :created_at

    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :role, Role
  end

  relationships do
    belongs_to :community, CovenantAI.Communities.Community
  end

  authentication do
    tokens do
      enabled? true
      token_resource CovenantAI.Accounts.Token
      store_all_tokens? true
      require_token_presence_for_authentication? true

      signing_secret fn _, _ ->
        Application.fetch_env(:covenant_ai, :token_signing_secret)
      end
    end

    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password

        sign_in_tokens_enabled? true
      end
    end
  end

  actions do
    defaults [:create, :destroy, :read, :update]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end
  end

  validations do
    validate attribute_in(:role, [:board_admin, :super_admin]) do
      on [:create]
    end
  end

  # You can customize this if you wish, but this is a safe default that
  # only allows user data to be interacted with via AshAuthentication.
  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    bypass actor_attribute_equals(:role, :super_admin) do
      authorize_if always()
    end

    policy action_type(:destroy) do
      authorize_if expr(id == ^actor(:id))
    end

    # Maybe update this. I do not want user information shared with unauthorized users.
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if expr(id == ^actor(:id))
    end
  end
end
