# == Schema Information
#
# Table name: tickets
#
#  id                     :integer          not null, primary key
#  code                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  purchaser_email        :string
#  purchaser_first_name   :string
#  purchaser_last_name    :string
#  event_id               :integer          not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  company_ticket_type_id :integer          not null
#

require "rails_helper"

RSpec.describe Ticket, type: :model do
  it { is_expected.to validate_presence_of(:code) }
end
