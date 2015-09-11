# == Schema Information
#
# Table name: customer_event_profiles
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer
#  ticket_id                 :integer
#  deleted_at                :datetime
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe CustomerEventProfile, type: :model do
  it { is_expected.to validate_presence_of(:customer) }
  it { is_expected.to validate_presence_of(:event) }


end
