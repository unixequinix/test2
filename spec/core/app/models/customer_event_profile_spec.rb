# == Schema Information
#
# Table name: customer_event_profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#  deleted_at  :datetime
#

require "rails_helper"

RSpec.describe CustomerEventProfile, type: :model do
  it { is_expected.to validate_presence_of(:event) }

  context "The relation" do
    describe "active_assignments" do
      it "should return the gtags and tickets assigned" do
        customer_event_profile = create(:customer_event_profile)
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
      credit_log = create(:credit_log, amount: 9)
      customer_event_profile = credit_log.customer_event_profile
      expect(customer_event_profile.total_credits).to be(9)

      credit_log = create(:credit_log, amount: 9.0)
      customer_event_profile = credit_log.customer_event_profile
      expect(customer_event_profile.total_credits).to be(9)

      credit_log = create(:credit_log, amount: 9.2)
      customer_event_profile = credit_log.customer_event_profile
      expect(customer_event_profile.total_credits).to be(9)

      credit_log = create(:credit_log, amount: 9.7)
      customer_event_profile = credit_log.customer_event_profile
      expect(customer_event_profile.total_credits).to be(9)
    end
  end

  describe "ticket_credits method" do
    it "should return the amount of credits rounded" do
      customer_event_profile = create(:customer_event_profile)
      create(
        :credit_log,
        customer_event_profile: customer_event_profile,
        transaction_type: "ticket_assignment",
        amount: 1.2)
      create(
        :credit_log,
        customer_event_profile: customer_event_profile,
        transaction_type: "ticket_assignment",
        amount: 2.5)
      expect(customer_event_profile.ticket_credits).to be(3)
    end

    it "should return the total amount of credits" do
      customer_event_profile = create(:customer_event_profile)

      5.times do |time|
        create(
          :credit_log,
          customer_event_profile: customer_event_profile,
          transaction_type: "ticket_assignment",
          amount: time)
      end

      expect(customer_event_profile.ticket_credits).to be(10)
    end

    it "should return the total amount of credits,
      only if the transaction_type is ticket_assignment" do
      customer_event_profile = create(:customer_event_profile)

      3.times do |time|
        create(
          :credit_log,
          customer_event_profile: customer_event_profile,
          transaction_type: "ticket_assignment",
          amount: time)
      end

      2.times do |time|
        create(
          :credit_log,
          customer_event_profile: customer_event_profile,
          transaction_type: "credits_purchase",
          amount: time)
      end

      expect(customer_event_profile.ticket_credits).to be(3)
    end
  end

  describe "purchased_credits method" do
    it "should return the amount of credits rounded" do
      customer_event_profile = create(:customer_event_profile)

      create(
        :credit_log,
        customer_event_profile: customer_event_profile,
        transaction_type: "credits_purchase",
        amount: 1.7)
      create(
        :credit_log,
        customer_event_profile: customer_event_profile,
        transaction_type: "credits_purchase",
        amount: 2.7)
      expect(customer_event_profile.purchased_credits).to be(4)
    end

    it "should return the amount of purchased credits" do
      customer_event_profile = create(:customer_event_profile)

      5.times do |time|
        create(
          :credit_log,
          customer_event_profile: customer_event_profile,
          transaction_type: "credits_purchase",
          amount: time)
      end

      expect(customer_event_profile.purchased_credits).to be(10)
    end

    it "should return the total amount of credits,
      only if the transaction_type is credits_purchase" do
      customer_event_profile = create(:customer_event_profile)

      3.times do |time|
        create(
          :credit_log,
          customer_event_profile: customer_event_profile,
          transaction_type: "ticket_assignment",
          amount: time)
      end

      2.times do |time|
        create(
          :credit_log,
          customer_event_profile: customer_event_profile,
          transaction_type: "credits_purchase",
          amount: time)
      end

      expect(customer_event_profile.purchased_credits).to be(1)
    end
  end

  describe "refundable_credits method" do
    it "should return nil if assigned_gtag_registration is nil" do
      customer_event_profile = create(:customer_event_profile)
      expect(customer_event_profile.refundable_credits).to be_nil
    end

    it "should return the amount of credits" do
      event = create(:event)
      gtag = create(:gtag, event: event)
      create(:gtag_credit_log, amount: 15, gtag: gtag)
      customer_event_profile = create(:customer_event_profile, event: event)
      create(:credential_assignment,
             credentiable: gtag,
             customer_event_profile: customer_event_profile,
             aasm_state: "assigned")
      expect(customer_event_profile.refundable_credits).to eq(15)
    end
  end
end
