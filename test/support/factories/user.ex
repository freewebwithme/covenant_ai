defmodule CovenantAI.Factories.User do
  alias CovenantAI.Accounts.User

  @spec super_admin() :: User.t()
  def super_admin do
    %User{
      id: Ash.UUID.generate(),
      email: Faker.Internet.email(),
      role: :super_admin
    }
  end

  @spec board_admin() :: User.t()
  def board_admin do
    %User{
      id: Ash.UUID.generate(),
      email: Faker.Internet.email(),
      role: :board_admin
    }
  end

  @spec board_member() :: User.t()
  def board_member do
    %User{
      id: Ash.UUID.generate(),
      email: Faker.Internet.email(),
      role: :board_member
    }
  end

  @spec resident() :: User.t()
  def resident do
    %User{
      id: Ash.UUID.generate(),
      email: Faker.Internet.email(),
      role: :resident
    }
  end
end
