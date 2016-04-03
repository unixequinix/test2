require "rails_helper"

RSpec.describe Management::RefundManager, type: :domain_logic do
  subject { Management::RefundManager }
  let(:profile) { create(:customer_event_profile) }

  describe ".check" do
    it "should return 'online' if profile has enogh online refundable money" do
      allow(profile).to receive(:online_refundable_money_amount).and_return(100.00)
      expect(subject.check(profile, 90)).to eq("online")
    end

    it "should return 'online if profile exactly matches online refundable money" do
      allow(profile).to receive(:online_refundable_money_amount).and_return(100.00)
      expect(subject.check(profile, 100)).to eq("online")
    end

    it "should return 'offline' otherwise" do
      allow(profile).to receive(:online_refundable_money_amount).and_return(100.00)
      expect(subject.check(profile, 110)).to eq("offline")
    end
  end

  describe ".get_online_payments" do
    let(:orders) { create_list(:order_with_payment, 3, customer_event_profile: profile) }
    let(:payments) { orders.map(&:payments).flatten }

    before { payments.each { |p| p.update_attributes! amount: 100, order: p.order } }

    it "should include the payents required to start the refund and respective amounts" do
      results = subject.get_online_payments(profile, 150)
      expect(results.map(&:last).sum).to be(150.0)
    end

    it "should not include more payments than necessary" do
      expect(subject.get_online_payments(profile, 150).size).to be(2)
    end

    it "should include the least amount of payments possible" do
      payments[rand(payments.size)].update_attributes! amount: 200
      expect(subject.get_online_payments(profile, 150).size).to be(1)
      expect(subject.get_online_payments(profile, 150).last.last).to be(150.0)
    end

    it "should include the remainder amount in the last transaction" do
      expect(subject.get_online_payments(profile, 150).last.last).to be(50.0)
    end

    it "should only include successfull payments" do
      payments[rand(payments.size)].update_attributes! amount: 200, success: false
      expect(subject.get_online_payments(profile, 150).size).to be(2)
      expect(subject.get_online_payments(profile, 150).last.last).to be(50.0)
    end
  end
end
