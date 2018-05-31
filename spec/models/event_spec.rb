require "rails_helper"

RSpec.describe Event, type: :model do
  subject { build(:event) }

  describe ".valid_app_version?" do
    before { subject.app_version = "1.0.0.0" }

    it "returns true if version is higher" do
      expect(subject.valid_app_version?("1.0.0.1")).to be_truthy
    end

    it "returns true if version matches" do
      expect(subject.valid_app_version?("1.0.0.0")).to be_truthy
    end

    it "returns false if version is lower" do
      expect(subject.valid_app_version?("0.9.9.9")).to be_falsey
    end

    it "handles 3 digit versions with valid app version" do
      expect(subject.valid_app_version?("1.0.1")).to be_truthy
    end

    it "handles 3 digit versions with invalid app version" do
      expect(subject.valid_app_version?("0.9.1")).to be_falsey
    end

    it "handles pre-release versions" do
      expect(subject.valid_app_version?("1.0.1-beta")).to be_truthy
    end

    it "handles pre-release of the same version" do
      expect(subject.valid_app_version?("1.0.0.0-DEBUG")).to be_truthy
    end

    it "always returns true if the app_version is all" do
      subject.app_version = "all"
      expect(subject.valid_app_version?("notaversion")).to be_truthy
      expect(subject.valid_app_version?(nil)).to be_truthy
      expect(subject.valid_app_version?([])).to be_truthy
    end
  end

  describe ".event_serie_id" do
    before do
      create(:event_serie, :with_events, associated_events: subject)
    end

    it "returns event_serie_id" do
      expect(subject.event_serie_id).not_to be_nil
    end
  end

  describe ".currency_symbol" do
    it "returns symbol" do
      expect(subject.currency_symbol).to be_a(String)
    end

    it "add errors if currency is blank" do
      subject.currency = nil
      expect(subject.currency_symbol).to be_nil
    end
  end

  describe "reports methods" do
    before(:each) do
      create(:credit, event: subject, value: 2)

      @online_topups = create_list(:order, 3, event: subject, money_base: 10, money_fee: 5)
      @online_topups.map(&:complete!)
      @onsite_topups = create_list(:poke, 3, :as_topups, event: subject)
      @sales = create_list(:poke, 3, :as_sales, event: subject)
      @purchases = create_list(:poke, 3, :as_purchase, event: subject)
      @customers = create_list(:customer, 3, event: subject, anonymous: false)
      @customers.each do |customer|
        gtag = create(:gtag, event: subject, customer: customer, credits: rand(10..50))
        customer.reload
        create(:refund, event: subject, customer: customer, credit_base: gtag.credits, status: 2)
      end
    end

    it "should calculate onsite spending power" do
      onsite_spending_power = @sales.sum(&:credit_amount)
      expect(subject.onsite_spending_power).to eq(onsite_spending_power * subject.credit.value)
    end

    it "should calculate online spending power" do
      online_spending_power = -1 * subject.refunds.completed.sum("credit_base")
      expect(subject.online_spending_power).to eq(online_spending_power * subject.credit.value)
    end

    it "should calculate spending power" do
      onsite_spending_power = @sales.sum(&:credit_amount)
      online_spending_power = -1 * subject.refunds.completed.sum("credit_base")
      expect(subject.total_spending_power).to eq((onsite_spending_power + online_spending_power) * subject.credit.value)
    end
  end
end
