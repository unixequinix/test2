require "rails_helper"

RSpec.describe ClaimParameter, type: :model do
  describe "for_category" do
    it "should return the event and the parameters for a category" do
      claim_parameter = create(:claim_parameter)
      category = claim_parameter.parameter.category
      event = claim_parameter.claim.gtag.event
      expect(ClaimParameter.for_category(category, event)).not_to be_nil
    end
  end
end