require "rails_helper"

RSpec.describe EpgCheckout, type: :domain_logic do
  before(:all) do
    event = create(:event, refund_services: 2)
    Seeder::SeedLoader.load_default_event_parameters(event)
    cep = create(:customer_event_profile, event: event)
    gtag = create(:gtag, event: event)
    create(:claim, customer_event_profile: cep, gtag: gtag)
    create(:online_product, event: event, price: 20)
    create(:credit, standard: true)
    claim = CustomerEventProfile.find_by(event: event).claims.first
    epg_claim_form = EpgClaimForm.new(country_code: "ES",
                                      state: "Madrid",
                                      city: "Madrid",
                                      post_code: "28004",
                                      phone: +34_660_556_776,
                                      address: "C/Conde Romanones",
                                      claim_id: claim.id,
                                      agreed_on_claim: true)
    @epg_checkout_service = EpgCheckout.new(claim, epg_claim_form)
  end

  describe "when a new instance is created" do
    it "should initialize the attributes of a epg_checkout_service" do
      expect(@epg_checkout_service.instance_variable_get(:@claim)).not_to be_nil
      expect(@epg_checkout_service.instance_variable_get(:@epg_claim_form)).not_to be_nil
      expect(@epg_checkout_service.instance_variable_get(:@epg_values)).not_to be_nil
    end
  end

  describe "the url method" do
    it "should return a valid url for epg" do
      uri = URI.parse(@epg_checkout_service.url)
      expect(%w(http https)).to include(uri.scheme)
    end
  end
end
