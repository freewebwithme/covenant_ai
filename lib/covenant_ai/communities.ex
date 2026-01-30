defmodule CovenantAI.Communities do
  use Ash.Domain, otp_app: :covenant_ai, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource __MODULE__.Community
    resource __MODULE__.Document
  end
end
