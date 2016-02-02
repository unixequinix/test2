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
  it { is_expected.to validate_presence_of(:company) }

  describe "CompanyTicketType" do
    before(:all) do
      @company = create(:company)
      @event = @company.event
      create(:company_ticket_type, company: @company, event: @event, name: "Jaquan", id: 1)
      create(:company_ticket_type, company: @company, event: @event, name: "Hilario", id: 2)
      create(:company_ticket_type, company: @company, event: @event, name: "Lloyd", id: 3)
      create(:company_ticket_type, company: @company, event: @event, name: "Francis", id: 4)
      create(:company_ticket_type, company: @company, event: @event, name: "Ronny", id: 5)
      create(:company_ticket_type, company: @company, event: @event, name: "Emie", id: 6)
      create(:company_ticket_type, company: @company, event: @event, name: "Donna", id: 7)
      create(:company_ticket_type, company: @company, event: @event, name: "Ruthe", id: 8)
      create(:company_ticket_type, company: @company, event: @event, name: "Brooks", id: 9)
      create(:company_ticket_type, company: @company, event: @event, name: "Leonora", id: 10)
    end

    it "returns all the company ticket types thant belongs to a company of a particular event" do
      query = CompanyTicketType.search_by_company_and_event(@company.name, @event)
      expect(query.count).to eq(10)
    end
    it "returns the data in the proper format for select inputs" do
      query = CompanyTicketType.form_selector(@event)
      expect(query).to eq([
        ["Jaquan", 1],
        ["Hilario", 2],
        ["Lloyd", 3],
        ["Francis", 4],
        ["Ronny", 5],
        ["Emie", 6],
        ["Donna", 7],
        ["Ruthe", 8],
        ["Brooks", 9],
        ["Leonora", 10]
      ])
    end
  end
end
