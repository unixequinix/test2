require "rails_helper"

RSpec.describe CredentialType, type: :model do
  context "Before the creation of a new credential type" do
    it "should set the memory position as the last position in the collection" do
      event = create(:event)

      first_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(first_credential_type.memory_position).to eq(1)

      second_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(second_credential_type.memory_position).to eq(2)

      second_credential_type.destroy

      third_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(third_credential_type.memory_position).to eq(2)
    end

    it "should rearrange the memory position of the existing credential types when one is deleted" do
      event = create(:event)

      first_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(first_credential_type.memory_position).to eq(1)

      second_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(second_credential_type.memory_position).to eq(2)

      third_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(third_credential_type.memory_position).to eq(3)

      fourth_credential_type = create(:preevent_item_credential, event: event).purchasable
      expect(fourth_credential_type.memory_position).to eq(4)

      second_credential_type.destroy

      binding.pry

      expect(CredentialType.find(third_credential_type.id).memory_position).to eq(2)
      expect(CredentialType.find(fourth_credential_type.id).memory_position).to eq(3)
    end
  end
end