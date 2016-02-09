# == Schema Information
#
# Table name: purchasers
#
#  id                    :integer          not null, primary key
#  credentiable_id       :integer          not null
#  credentiable_type     :string           not null
#  first_name            :string           not null
#  last_name             :string           not null
#  email                 :string           not null
#  gtag_delivery_address :string
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require "rails_helper"

RSpec.describe Purchaser, type: :model do
end
