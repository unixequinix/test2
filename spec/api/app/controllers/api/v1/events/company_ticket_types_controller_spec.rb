require "rails_helper"

RSpec.describe Api::V1::Events::CompanyTicketTypesController, type: :controller do
  subject { Api::V1::Events::CompanyTicketTypesController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'company_ticket_type'" do
      expect(subject).to receive(:render_entities).with("company_ticket_type").once
      subject.index
    end
  end
end
