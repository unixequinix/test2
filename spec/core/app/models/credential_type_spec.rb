require "rails_helper"

RSpec.describe CredentialType, type: :model do
  context "Before the creation of a new credential type" do
    it "should set the memory position as the last position in the collection" do
      event = create(:event)
      first_credential_type = create(:credit_catalog_item, :with_credential_type, event: event).credential_type
      expect(first_credential_type.memory_position).to eq(1)

      second_credential_type = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(second_credential_type.memory_position).to eq(2)

      second_credential_type.destroy

      third_credential_type = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(third_credential_type.memory_position).to eq(2)
    end

    it "rearranges the memory position of the existing credential types when one is deleted" do
      event = create(:event)

      first_credential_type = create(:credit_catalog_item, :with_credential_type, event: event).credential_type
      expect(first_credential_type.memory_position).to eq(1)

      second_credential_type = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(second_credential_type.memory_position).to eq(2)

      third_credential_type = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(third_credential_type.memory_position).to eq(3)

      fourth_credential_type = create(:credit_catalog_item, :with_credential_type, event: event).credential_type
      expect(fourth_credential_type.memory_position).to eq(4)

      second_credential_type.destroy

      expect(CredentialType.find(third_credential_type.id).memory_position).to eq(2)
      expect(CredentialType.find(fourth_credential_type.id).memory_position).to eq(3)
    end
  end
end
