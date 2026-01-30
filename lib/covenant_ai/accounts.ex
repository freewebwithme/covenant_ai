defmodule CovenantAI.Accounts do
  use Ash.Domain, otp_app: :covenant_ai, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource __MODULE__.User
    resource __MODULE__.Token
  end
end
