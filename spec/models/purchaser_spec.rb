# == Schema Information
#
# Table name: purchasers
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  surname    :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Purchaser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
