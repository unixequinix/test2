# == Schema Information
#
# Table name: entitlement_ticket_types
#
#  id             :integer          not null, primary key
#  entitlement_id :integer          not null
#  ticket_type_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

require "rails_helper"

RSpec.describe EntitlementTicketType, type: :model do
  it { is_expected.to validate_presence_of(:entitlement) }
  it { is_expected.to validate_presence_of(:ticket_type) }
end
