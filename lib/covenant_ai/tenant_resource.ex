defmodule CovenantAI.TenantResource do
  @moduledoc """
  Provides attribute-based multitenancy configuration for Ash resources.

  This macro sets up community-scoped multitenancy with automatic
  tenant filtering and super_admin bypass capabilities.

  ## Usage

      defmodule CovenantAI.SomeResource do
        use Ash.Resource, ...
        use CovenantAI.TenantResource

        # Your resource definition
      end
  """

  defmacro __using__(_opts) do
    quote do
      multitenancy do
        strategy :attribute
        attribute :community_id
      end
    end
  end
end
