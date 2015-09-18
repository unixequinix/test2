# == Schema Information
#
# Table name: orders
#
#  id           :integer          not null, primary key
#  customer_id  :integer          not null
#  number       :string           not null
#  aasm_state   :string           not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require "rails_helper"

RSpec.describe Order, type: :model do
  it { is_expected.to validate_presence_of(:customer_event_profile) }
  it { is_expected.to validate_presence_of(:order_items) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:aasm_state) }

end
