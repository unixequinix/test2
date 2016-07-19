require "rails_helper"

RSpec.describe Profile, type: :model do
  it { is_expected.to validate_presence_of(:event) }
  let(:profile) { create(:profile) }
  let(:atts) { { profile: profile } }

  context "when dealing with credits" do
    describe ".online_refundable_money" do
      it "returns the sum of all refundable online money from previous purchases made" do
        orders = create_list(:order_with_payment, 3, profile: profile)
        payments = orders.map(&:payments).flatten
        amount = payments.map(&:amount).sum
        expect(amount > 0).to be_truthy
        expect(profile.online_refundable_money).to eq(amount)
      end

      it "retuns 0 if no purchases are present" do
        expect(profile.online_refundable_money).to eq(0)
      end
    end
  end

  it "The relation active_assignments returns the gtags and tickets assigned" do
    create(:credential_assignment_g_a, atts)
    create(:credential_assignment_g_u, atts)
    create(:credential_assignment_t_a, atts)
    create(:credential_assignment_t_u, atts)

    expect(profile.active_assignments.count).to be(2)
  end
end
