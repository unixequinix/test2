# == Schema Information
#
# Table name: admittances
#
#  id           :integer          not null, primary key
#  admission_id :integer
#  ticket_id    :integer
#  aasm_state   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Admittance, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
