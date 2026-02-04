defmodule CovenantAI.Communities.CommunityTest do
  use CovenantAI.DataCase

  alias CovenantAI.Communities.Community

  import CovenantAI.Factories.{Community, User}

  describe "create action" do
    test "creates a community with valid attributes" do
      attrs = valid_community_attributes()

      assert {:ok, community} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()

      assert community.name == attrs.name
      assert community.status == :inactive
      assert community.address.city == attrs.address.city
      assert community.contact_email == attrs.contact_email
    end

    test "cannot be created with board member or resident" do
      attrs = valid_community_attributes()

      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: board_member())
               |> Ash.create()

      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: resident())
               |> Ash.create()
    end

    test "requires name" do
      attrs = valid_community_attributes() |> Map.delete(:name)

      assert {:error, %{errors: [%Ash.Error.Changes.Required{field: :name}]}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()
    end

    test "requires address" do
      attrs = valid_community_attributes() |> Map.delete(:address)

      assert {:error, %{errors: [%Ash.Error.Changes.Required{field: :address}]}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()
    end

    test "sets default status to inactive" do
      attrs = valid_community_attributes() |> Map.delete(:status)

      assert {:ok, community} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()

      assert community.status == :inactive
    end

    test "validates address state format" do
      attrs =
        valid_community_attributes()
        |> put_in([:address, :state], "California")

      assert {:error,
              %Ash.Error.Invalid{errors: [%Ash.Error.Changes.InvalidAttribute{field: :state}]}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()
    end

    test "validates address zip_code format" do
      attrs =
        valid_community_attributes()
        |> put_in([:address, :zip_code], "1234")

      assert {:error,
              %Ash.Error.Invalid{errors: [%Ash.Error.Changes.InvalidAttribute{field: :zip_code}]}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()
    end

    test "accepts zip_code in 5+4 format" do
      attrs =
        valid_community_attributes()
        |> put_in([:address, :zip_code], "12345-6789")

      assert {:ok, community} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()

      assert community.address.zip_code == "12345-6789"
    end
  end

  describe "read action" do
    test "reads a community successfully" do
      community = create_community()

      assert {:ok, fetched} =
               Community
               |> Ash.Query.filter(id == ^community.id)
               |> Ash.read_one(actor: super_admin())

      assert fetched.id == community.id
      assert fetched.name == community.name
    end

    test "reads multiple communities" do
      community1 = create_community()
      community2 = create_community()

      assert {:ok, communities} =
               Community
               |> Ash.read(actor: super_admin())

      assert length(communities) >= 2
      assert Enum.any?(communities, &(&1.id == community1.id))
      assert Enum.any?(communities, &(&1.id == community2.id))
    end
  end

  describe "update action" do
    setup :setup_community

    test "updates community with valid attributess as a super admin", %{community: com} do
      new_name = Faker.Company.name()
      new_address = valid_address_attributes()

      assert {:ok, updated} =
               com
               |> Ash.Changeset.for_update(
                 :update,
                 %{name: new_name, address: new_address, status: :active},
                 actor: super_admin()
               )
               |> Ash.update()

      assert updated.name == new_name
      assert updated.address.street_address == new_address.street_address
      assert updated.id == com.id
      assert updated.status == :active
    end

    test "updates community contact as a board admin", %{community: com} do
      assert {:ok, updated} =
               com
               |> Ash.Changeset.for_update(
                 :update_contact,
                 %{contact_email: "new_email@example.com"},
                 actor: board_admin()
               )
               |> Ash.update()

      assert updated.contact_email == "new_email@example.com"
    end

    test "validates address on update", %{community: com} do
      invalid_address =
        valid_address_attributes()
        |> Map.put(:state, "invalid")

      assert {:error, %Ash.Error.Invalid{}} =
               com
               |> Ash.Changeset.for_update(
                 :update,
                 %{address: invalid_address},
                 actor: super_admin()
               )
               |> Ash.update()
    end
  end

  describe "authorization policies - create" do
    setup do
      %{attrs: valid_community_attributes()}
    end

    test "super_admin can create community", %{attrs: attrs} do
      assert {:ok, _community} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: super_admin())
               |> Ash.create()
    end

    test "board_admin cannot create community", %{attrs: attrs} do
      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: board_admin())
               |> Ash.create()
    end

    test "board_member cannot create community" do
      attrs = valid_community_attributes()

      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: board_member())
               |> Ash.create()
    end

    test "resident cannot create community" do
      attrs = valid_community_attributes()

      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs, actor: resident())
               |> Ash.create()
    end

    test "unauthenticated user cannot create community" do
      attrs = valid_community_attributes()

      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Changeset.for_create(:create, attrs)
               |> Ash.create()
    end
  end

  describe "authorization policies - read" do
    setup :setup_community

    test "super_admin can read community", %{community: community} do
      assert {:ok, fetched} =
               Community
               |> Ash.Query.filter(id == ^community.id)
               |> Ash.read_one(actor: super_admin())

      assert fetched.id == community.id
    end

    test "board_admin can read community", %{community: community} do
      assert {:ok, fetched} =
               Community
               |> Ash.Query.filter(id == ^community.id)
               |> Ash.read_one(actor: board_admin())

      assert fetched.id == community.id
    end

    test "resident can read community", %{community: community} do
      assert {:ok, fetched} =
               Community
               |> Ash.Query.filter(id == ^community.id)
               |> Ash.read_one(actor: resident())

      assert fetched.id == community.id
    end

    test "board_member can read community", %{community: community} do
      assert {:ok, fetched} =
               Community
               |> Ash.Query.filter(id == ^community.id)
               |> Ash.read_one(actor: board_member())

      assert fetched.id == community.id
    end

    test "unauthenticated user cannot read community", %{community: community} do
      assert {:error, %Ash.Error.Forbidden{}} =
               Community
               |> Ash.Query.filter(id == ^community.id)
               |> Ash.read_one(authorize_with: :error)
    end
  end

  describe "authorization policies - update" do
    setup :setup_community

    test "super_admin can update community", %{community: community} do
      assert {:ok, updated} =
               community
               |> Ash.Changeset.for_update(
                 :update,
                 %{name: "Updated Name"},
                 actor: super_admin()
               )
               |> Ash.update()

      assert updated.name == "Updated Name"
    end

    test "board_admin cannot update community", %{community: community} do
      assert {:error, %Ash.Error.Forbidden{}} =
               community
               |> Ash.Changeset.for_update(
                 :update,
                 %{name: "Updated Name"},
                 actor: board_admin()
               )
               |> Ash.update()
    end

    test "board_member cannot update community", %{community: community} do
      assert {:error, %Ash.Error.Forbidden{}} =
               community
               |> Ash.Changeset.for_update(
                 :update,
                 %{name: "Updated Name"},
                 actor: board_member()
               )
               |> Ash.update()
    end

    test "resident cannot update community", %{community: community} do
      assert {:error, %Ash.Error.Forbidden{}} =
               community
               |> Ash.Changeset.for_update(
                 :update,
                 %{name: "Updated Name"},
                 actor: resident()
               )
               |> Ash.update()
    end
  end
end
