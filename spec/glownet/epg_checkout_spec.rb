require "rails_helper"

# TODO: Refactor this test
RSpec.describe EpgCheckout, type: :domain_logic do
  before(:all) do
    ClaimParameter.destroy_all
    Refund.destroy_all
    Claim.destroy_all
    credential_assignment = create(:credential_assignment_g_a)
    gtag = credential_assignment.credentiable
    event = gtag.event
    event.update_attribute(:refund_services, 2)
    profile = create(:profile, :with_customer, event: event)
    Seeder::SeedLoader.load_default_event_parameters(event)
    create(:claim, profile: profile, gtag: gtag)
    create(:full_catalog_item, event: event)
    claim = Profile.find_by(event: event).claims.first
    epg_claim_form = EpgClaimForm.new(country_code: "ES",
                                      state: "Madrid",
                                      city: "Madrid",
                                      post_code: "28004",
                                      phone: "660556776",
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
