defmodule CovenantAI.Factories.Community do
  alias CovenantAI.Communities.Community

  import CovenantAI.Factories.User

  @spec valid_community_attributes() :: map()
  def valid_community_attributes do
    %{
      name: Faker.Company.name(),
      address: valid_address_attributes(),
      status: :inactive,
      contact_email: Faker.Internet.email(),
      contact_phone: Faker.Phone.EnUs.phone()
    }
  end

  @spec valid_address_attributes() :: map()
  def valid_address_attributes do
    %{
      street_address: Faker.Address.street_address(),
      city: Faker.Address.city(),
      state: Faker.Address.state_abbr(),
      zip_code: Faker.Address.zip_code(),
      country: "US"
    }
  end

  @spec create_community() :: Community.t()
  def create_community do
    attrs = valid_community_attributes()

    Community
    |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
    |> Ash.create!()
  end

  def setup_community(ctx) do
    Map.put(ctx, :community, create_community())
  end
end
