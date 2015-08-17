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
  pending "add some examples to (or delete) #{__FILE__}"
end
