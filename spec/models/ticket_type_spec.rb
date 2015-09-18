# == Schema Information
#
# Table name: ticket_types
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  company         :string           not null
#  credit          :decimal(8, 2)    default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  simplified_name :string
#

require "rails_helper"

RSpec.describe TicketType, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:company) }
  it { is_expected.to validate_presence_of(:credit) }
end
