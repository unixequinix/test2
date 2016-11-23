# == Schema Information
#
# Table name: ticket_types
#
#  company_code               :string
#  created_at                 :datetime         not null
#  name                       :string
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_ticket_types_on_catalog_item_id             (catalog_item_id)
#  index_ticket_types_on_company_event_agreement_id  (company_event_agreement_id)
#  index_ticket_types_on_event_id                    (event_id)
#
# Foreign Keys
#
#  fk_rails_46208a732b  (event_id => events.id)
#  fk_rails_4abbce3a9c  (catalog_item_id => catalog_items.id)
#  fk_rails_6f2c36d14d  (company_event_agreement_id => company_event_agreements.id)
#

require "spec_helper"

RSpec.describe TicketType, type: :model do
  subject { build(:ticket_type) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to allow_value("", nil).for(:company_code) }

  let(:event) { create(:event) }
  let(:agreement) { create(:company_event_agreement, event: event) }
  let(:ticket_type) do
    create(:ticket_type, company_event_agreement: agreement, event: event, name: "Jaquan")
  end
  let(:ticket_type2) do
    create(:ticket_type, company_event_agreement: agreement, event: event, name: "Hilario")
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".hide!" do
    it "changes the hidden value to true" do
      subject.save
      expect do
        subject.hide!
      end.to change(subject, :hidden).from(false).to(true)
    end
  end

  describe ".show!" do
    it "changes the hidden value to true" do
      subject.hidden = true
      subject.save
      expect do
        subject.show!
      end.to change(subject, :hidden).from(true).to(false)
    end
  end

  # TODO: Refactor this test
  describe "TicketType queries" do
    before :each do
      # Initialize to save in DB
      ticket_type.inspect
      ticket_type2.inspect
    end

    it "returns the data in the proper format for select inputs" do
      query = TicketType.form_selector(event)
      expect(query).to include(["Jaquan", ticket_type.id])
      expect(query).to include(["Hilario", ticket_type2.id])
    end
  end
end
