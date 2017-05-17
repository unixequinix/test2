require "spec_helper"

RSpec.describe Ticket, type: :model do
  let(:event) { build(:event) }
  let(:customer) { build(:customer, event: event) }
  subject { build(:ticket, customer: customer, event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "can look for checkin gtag and assign it to its customer" do
    subject.save!
    gtag = create(:gtag, event: event)
    create(:credential_transaction, action: "ticket_checkin", status_code: 0, ticket_id: subject.id, event: event, gtag: gtag)

    subject.assign_gtag
    expect(customer.active_gtag).to eq(gtag)
  end
end
