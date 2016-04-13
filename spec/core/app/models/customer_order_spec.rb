# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  event_id                  :integer          not null
#  preevent_product_id       :integer          not null
#  customer_event_profile_id :integer          not null
#  counter                   :integer
#  aasm_state                :string           default("unredeemed"), not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require "rails_helper"

RSpec.describe CustomerOrder, type: :model do
  it { is_expected.to validate_presence_of(:catalog_item_id) }
  it { is_expected.to validate_presence_of(:customer_event_profile_id) }
end
