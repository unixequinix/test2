# == Schema Information
#
# Table name: tickets
#
#  banned               :boolean          default(FALSE)
#  code                 :citext
#  purchaser_email      :string
#  purchaser_first_name :string
#  purchaser_last_name  :string
#  redeemed             :boolean          default(FALSE), not null
#
# Indexes
#
#  index_tickets_on_code_and_event_id  (code,event_id) UNIQUE
#  index_tickets_on_customer_id        (customer_id)
#  index_tickets_on_event_id           (event_id)
#  index_tickets_on_ticket_type_id     (ticket_type_id)
#
# Foreign Keys
#
#  fk_rails_4def87ea62  (event_id => events.id)
#  fk_rails_5685ed71b0  (customer_id => customers.id)
#  fk_rails_9ee4d47696  (ticket_type_id => ticket_types.id)
#

require "spec_helper"

RSpec.describe Ticket, type: :model do
  subject { build(:ticket) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
