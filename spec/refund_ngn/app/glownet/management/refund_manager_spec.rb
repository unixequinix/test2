require "rails_helper"

RSpec.describe Management::RefundManager, type: :domain_logic do
  let(:profile) { create(:customer_event_profile) }
  let(:amount) { profile.refundable_money_amount }
  subject { Management::RefundManager.new(profile, amount) }

  describe ".get_online_payments" do
    let(:orders) { create_list(:order_with_payment, 3, customer_event_profile: profile) }
    let(:payments) { orders.map(&:payments).flatten }

    before do
      payments.each { |p| p.update_attributes! amount: 100, order: p.order }
      allow(profile).to receive(:refundable_money_amount).and_return(150.00)
    end

    it "should include the payents required to start the refund and respective amounts" do
      results = subject.online_payments
      expect(results.map(&:last).sum).to be(150.0)
    end

    it "should not include more payments than necessary" do
      expect(subject.online_payments.size).to be(2)
    end

    it "should include the least amount of payments possible" do
      payments[rand(payments.size)].update_attributes! amount: 200
      expect(subject.online_payments.size).to be(1)
      expect(subject.online_payments.last.last).to be(150.0)
    end

    it "should include the remainder amount in the last transaction" do
      expect(subject.online_payments.last.last).to be(50.0)
    end

    it "should only include successfull payments" do
      payments[rand(payments.size)].update_attributes! amount: 200, success: false
      expect(subject.online_payments.size).to be(2)
      expect(subject.online_payments.last.last).to be(50.0)
    end
  end
end
