defmodule CovenantAI.Communities.Address do
  @moduledoc """
  Represents a physical address.

  This is an embedded resource that can be used across different
  entities (Community, Unit, Resident profile, etc).
  """
  use Ash.Resource,
    data_layer: :embedded,
    domain: CovenantAI.Communities,
    otp_app: :covenant_ai

  attributes do
    attribute :street_address, :string, allow_nil?: false
    attribute :street_address_2, :string
    attribute :city, :string, allow_nil?: false
    attribute :state, :string, allow_nil?: false
    attribute :zip_code, :string, allow_nil?: false

    attribute :country, :string do
      default "US"
      allow_nil? false
    end
  end

  calculations do
    calculate :full_address, :string do
      description "Complete formatted address"

      calculation fn records, _context ->
        Enum.map(records, fn record ->
          parts = [
            record.street_address,
            record.street_address_2,
            record.city,
            "#{record.state} #{record.zip_code}",
            record.country
          ]

          parts
          |> Enum.reject(&is_nil/1)
          |> Enum.reject(&(&1 == ""))
          |> Enum.join(", ")
        end)
      end
    end

    calculate :short_address, :string do
      description "City, State format"

      calculation fn records, _context ->
        Enum.map(records, fn record ->
          "#{record.city}, #{record.state}"
        end)
      end
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :street_address,
        :street_address_2,
        :city,
        :state,
        :zip_code,
        :country
      ]
    end

    update :update do
      accept [
        :street_address,
        :street_address_2,
        :city,
        :state,
        :zip_code,
        :country
      ]
    end
  end

  validations do
    validate match(:state, ~r/^[A-Z]{2}$/) do
      message "State must be a 2-letter uppercase code"
    end

    validate match(:zip_code, ~r/^\d{5}(-\d{4})?$/) do
      message "ZIP code must be 5 digits or 5+4 format"
    end

    validate present(:street_address)
    validate present(:city)
  end
end
