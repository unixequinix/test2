# == Schema Information
#
# Table name: preevent_products
#
#  id                   :integer          not null, primary key
#  event_id             :integer          not null
#  name                 :string
#  online               :boolean          default(FALSE), not null
#  initial_amount       :integer
#  step                 :integer
#  max_purchasable      :integer
#  min_purchasable      :integer
#  price                :decimal(, )
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  preevent_items_count :integer          default(0), not null
#

require "rails_helper"

RSpec.describe PreeventProduct, type: :model do
end
