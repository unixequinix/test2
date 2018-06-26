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

  describe "update emv stations on emv fields changes" do
    let!(:topup_station) { create(:station, category: 'top_up_refund') }
    let!(:pos_station) { create(:station, category: 'vendor') }

    it "should update topup stations" do
      subject.update! emv_topup_enabled: true
      expect(topup_station.updated_at.to_s).to eq(subject.updated_at.to_s)
    end

    it "should update pos stations" do
      subject.update! emv_pos_enabled: true
      expect(pos_station.updated_at.to_s).to eq(subject.updated_at.to_s)
    end
  end

  describe "store_redirection" do
    let(:customer) { create(:customer, event: subject) }

    before { subject.update! auto_refunds: true }

    context "orders redirection" do
      it "should be to wiredlion" do
        expect(subject.store_redirection(customer, :order)).to include("wiredlion")
      end

      it "should contain the glownet portion of the URL" do
        expect(subject.store_redirection(customer, :order)).to include("register")
      end

      it "should contain the customer id" do
        expect(subject.store_redirection(customer, :order)).to include(customer.id.to_s)
      end
    end

    context "refunds redirection" do
      before(:each) do
        create(:gtag, event: subject, customer: customer)
      end

      it "not be new refunds path" do
        expect(subject.store_redirection(customer, :refund, gtag_uid: customer.active_gtag.tag_uid)).not_to eql("/#{subject.slug}/refunds/new")
      end

      it "should contain the glownet portion of the URL" do
        expect(subject.store_redirection(customer, :refund, gtag_uid: customer.active_gtag.tag_uid)).to include("refund")
      end

      it "should contain the customer email" do
        expect(subject.store_redirection(customer, :refund, gtag_uid: customer.active_gtag.tag_uid)).to include(customer.email.split("@").first)
      end

      it "should contain the customer gtag_id" do
        expect(subject.store_redirection(customer, :refund, gtag_uid: customer.active_gtag.tag_uid)).to include(customer.active_gtag.tag_uid)
      end
    end

    it "should contain dev if environment is not production" do
      expect(subject.store_redirection(customer, :order)).to include("dev")
    end

    it "should contain the event slug" do
      expect(subject.store_redirection(customer, :order)).to include(subject.slug)
    end

    it "should contain the protocol HTTPS" do
      expect(subject.store_redirection(customer, :order)).to include("http")
    end
  end
end
