require "rails_helper"

RSpec.describe CompanyEventAgreement, type: :model do
  it "has a valid factory" do
    expect(build(:company_event_agreement)).to be_valid
  end
end
