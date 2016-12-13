# == Schema Information
#
# Table name: companies
#
#  access_token :string
#  name         :string           not null
#

require "spec_helper"

RSpec.describe Company, type: :model do
  subject { create(:company, :with_company_event_agreement) }
  let(:event) { create(:event) }

  describe ".unassigned_events" do
    it "doesn't return the events that are already assigned to this company" do
      subject.events.each { |e| expect(subject.unassigned_events).not_to include(e) }
    end

    it "returns the events that are not assigned to this company" do
      expect(subject.unassigned_events).to include(event)
    end
  end

  describe ".generate_access_token" do
    it "generates a random token to the company" do
      expect(subject.access_token).not_to be_nil
    end
  end
end
