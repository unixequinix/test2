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
  it { is_expected.to allow_value("", nil).for(:company_code) }

  let(:event) { create(:event) }
  let(:agreement) { create(:company_event_agreement, event: event) }
  let(:ticket_type) do
    create(:company_ticket_type, company_event_agreement: agreement, event: event, name: "Jaquan")
  end
  let(:ticket_type2) do
    create(:company_ticket_type, company_event_agreement: agreement, event: event, name: "Hilario")
  end

  it "does not validate uniqueness when company_code is blank" do
    ticket_type.update! company_code: nil
    ticket_type2.update! company_code: ""
    expect(ticket_type).to be_valid
    expect(ticket_type2).to be_valid
  end

  describe "CompanyTicketType queries" do
    before :each do
      # Initialize to save in DB
      ticket_type.inspect
      ticket_type2.inspect
    end

    it "returns the data in the proper format for select inputs" do
      query = CompanyTicketType.form_selector(event)
      expect(query).to include(["Jaquan", ticket_type.id])
      expect(query).to include(["Hilario", ticket_type2.id])
    end
  end
end
