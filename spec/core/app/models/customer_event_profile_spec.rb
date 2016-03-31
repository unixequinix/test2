# == Schema Information
#
# Table name: customer_event_profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :daterand(100)         not null
#  updated_at  :daterand(100)         not null
#  event_id    :integer          not null
#  deleted_at  :daterand(100)
#

require "rails_helper"

RSpec.describe CustomerEventProfile, type: :model do
  it { is_expected.to validate_presence_of(:event) }
  let(:customer_event_profile) { create(:customer_event_profile) }

  context "The relation" do
    describe "active_assignments" do
      it "should return the gtags and tickets assigned" do
        create(:credential_assignment_g_a, customer_event_profile: customer_event_profile)
        create(:credential_assignment_g_u, customer_event_profile: customer_event_profile)
        create(:credential_assignment_t_a, customer_event_profile: customer_event_profile)
        create(:credential_assignment_t_u, customer_event_profile: customer_event_profile)

        expect(customer_event_profile.active_assignments.count).to be(2)
      end
    end
  end

  describe "total_credits method" do
    it "should return the number of credits rounded" do
      credit_log = create(:customer_credit_online)
      customer_event_profile = credit_log.customer_event_profile
      expect(customer_event_profile.total_credits).to eq(20)
    end
  end

  describe "ticket_credits method" do
    it "should return the amount of credits rounded" do
      create(:customer_credit_online,
             customer_event_profile: customer_event_profile,
             transaction_origin: "ticket_assignment")
      create(:customer_credit_online,
             customer_event_profile: customer_event_profile,
             transaction_origin: "ticket_assignment")
      expect(customer_event_profile.ticket_credits).to eq(40)
    end

    it "should return the total amount of credits" do
      create_list(:customer_credit_online, 2,
                  customer_event_profile: customer_event_profile,
                  transaction_origin: "ticket_assignment",
                  amount: 10)

      expect(customer_event_profile.ticket_credits).to eq(20)
    end

    it "should return the total amount of credits,
      only if the transaction_origin is ticket_assignment" do
      create_list(:customer_credit_online, 3,
                  customer_event_profile: customer_event_profile,
                  transaction_origin: "ticket_assignment",
                  amount: 1)

      create_list(:customer_credit_online, 3,
                  customer_event_profile: customer_event_profile,
                  transaction_origin: "credits_purchase",
                  amount: 1)

      expect(customer_event_profile.ticket_credits).to eq(3)
    end
  end

  describe "purchased_credits method" do
    it "should return the amount of credits rounded" do
      create(:customer_credit_online,
             customer_event_profile: customer_event_profile,
             transaction_origin: "credits_purchase",
             amount: 1.7)
      create(:customer_credit_online,
             customer_event_profile: customer_event_profile,
             transaction_origin: "credits_purchase",
             amount: 2.7)
      expect(customer_event_profile.purchased_credits).to eq(4)
    end

    it "should return the amount of purchased credits" do
      create_list(:customer_credit_online, 2,
                  customer_event_profile: customer_event_profile,
                  transaction_origin: "credits_purchase",
                  amount: 5)

      expect(customer_event_profile.purchased_credits).to eq(10)
    end

    it "should return the total amount of credits,
      only if the transaction_origin is credits_purchase" do
      create_list(:customer_credit_online, 3,
                  customer_event_profile: customer_event_profile,
                  transaction_origin: "ticket_assignment",
                  amount: 1)

      create_list(:customer_credit_online, 2,
                  customer_event_profile: customer_event_profile,
                  transaction_origin: "credits_purchase",
                  amount: 1)

      expect(customer_event_profile.purchased_credits).to eq(2)
    end
  end
end
