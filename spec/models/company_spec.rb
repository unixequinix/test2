# == Schema Information
#
# Table name: companies
#
#  access_token :string
#  name         :string           not null
#
# Indexes
#
#  index_companies_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_b64f18cd7d  (event_id => events.id)
#

require "spec_helper"

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
