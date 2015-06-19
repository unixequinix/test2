# == Schema Information
#
# Table name: admissions
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          default(1), not null
#  deleted_at  :datetime
#

require 'rails_helper'

RSpec.describe Admission, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
