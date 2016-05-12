# == Schema Information
#
# Table name: company_ticket_types
#
#  id                      :integer          not null, primary key
#  company_id              :integer
#  preevent_product_id     :integer
#  event_id                :integer
#  name                    :string
#  company_ticket_type_ref :string
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require "rails_helper"

RSpec.describe CompanyTicketType, type: :model do
  it { is_expected.to validate_presence_of(:name) }

  describe "CompanyTicketType" do
    before(:all) do
      @company_event_agreement = create(:company_event_agreement)
      @company = @company_event_agreement.company
      @event = @company_event_agreement.event
      @j = create(:company_ticket_type,
                  company_event_agreement: @company_event_agreement, event: @event, name: "Jaquan")
      @h = create(:company_ticket_type,
                  company_event_agreement: @company_event_agreement, event: @event, name: "Hilario")
    end

    it "returns all the company ticket types that belongs to a company of a particular event" do
      query = CompanyTicketType.search_by_company_and_event(@company.name, @event)
      expect(query.count).to eq(2)
    end

    it "returns the data in the proper format for select inputs" do
      query = CompanyTicketType.form_selector(@event)
      expect(query).to eq([
                            ["Jaquan", @j.id],
                            ["Hilario", @h.id]
                          ])
    end
  end
end
