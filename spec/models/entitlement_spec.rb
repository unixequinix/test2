# == Schema Information
#
# Table name: entitlements
#
#  memory_length   :integer          default(1)
#  memory_position :integer          not null
#  mode            :string           default("counter")
#
# Indexes
#
#  index_entitlements_on_access_id  (access_id)
#  index_entitlements_on_event_id   (event_id)
#
# Foreign Keys
#
#  fk_rails_dcf903a298  (event_id => events.id)
#

require "spec_helper"

RSpec.describe Entitlement, type: :model do
  let(:event) { create(:event) }
  let(:entitlement) { create(:entitlement, :with_access, event: event) }

  describe ".infinite?" do
    it "false for 'counter'" do
      allow(entitlement).to receive(:mode).and_return("counter")
      expect(entitlement.infinite?).to eq(false)
    end

    it "true for 'permanent'" do
      allow(entitlement).to receive(:mode).and_return("permanent")
      expect(entitlement.infinite?).to eq(true)
    end

    it "true for 'permanent_strict'" do
      allow(entitlement).to receive(:mode).and_return("permanent_strict")
      expect(entitlement.infinite?).to eq(true)
    end
  end

  context "before validations" do
    describe ".position " do
      it "adds the next memory_position to the new entitlement" do
        create(:access, entitlement: build(:entitlement, event: event))
        expect(entitlement.memory_position).to be(2)
      end
    end
  end
end
