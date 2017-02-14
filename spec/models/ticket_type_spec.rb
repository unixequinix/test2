# == Schema Information
#
# Table name: ticket_types
#
#  company_code    :string
#  name            :string
#
# Indexes
#
#  index_ticket_types_on_catalog_item_id  (catalog_item_id)
#  index_ticket_types_on_company_id       (company_id)
#  index_ticket_types_on_event_id         (event_id)
#
# Foreign Keys
#
#  fk_rails_46208a732b  (event_id => events.id)
#  fk_rails_4abbce3a9c  (catalog_item_id => catalog_items.id)
#  fk_rails_db490f924c  (company_id => companies.id)
#

require "spec_helper"

RSpec.describe TicketType, type: :model do
  subject { build(:ticket_type) }
  let(:event) { create(:event) }

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
end
