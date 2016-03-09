require "rails_helper"

RSpec.describe CredentialType, type: :model do
  context "Before the creation of a new credential type" do
    it "should set the memory position as the last position in the collection" do
      event = create(:event)
      ct1 = create(:credit_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct1.memory_position).to eq(1)

      ct2 = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct2.memory_position).to eq(2)

      ct2.destroy

      ct3 = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct3.memory_position).to eq(2)
    end

    it "rearranges the memory position of the existing credential types when one is deleted" do
      event = create(:event)

      ct1 = create(:credit_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct1.memory_position).to eq(1)

      ct2 = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct2.memory_position).to eq(2)

      ct3 = create(:access_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct3.memory_position).to eq(3)

      ct4 = create(:credit_catalog_item, :with_credential_type, event: event).credential_type
      expect(ct4.memory_position).to eq(4)

      ct2.destroy

      expect(CredentialType.find(ct3.id).memory_position).to eq(2)
      expect(CredentialType.find(ct4.id).memory_position).to eq(3)
    end
  end
end
