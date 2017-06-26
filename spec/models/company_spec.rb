require "rails_helper"

RSpec.describe Company, type: :model do
  subject { create(:company) }

  describe ".generate_access_token" do
    before { subject.generate_access_token }

    it "assigns a newly created random token" do
      expect(subject.access_token).not_to be_nil
    end

    it "is different form other companies" do
      expect(subject.access_token).not_to eql(create(:company).generate_access_token)
    end
  end
end
