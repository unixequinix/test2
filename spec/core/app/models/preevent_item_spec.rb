# == Schema Information
#
# Table name: preevent_items
#
#  id               :integer          not null, primary key
#  purchasable_id   :integer          not null
#  purchasable_type :string           not null
#  event_id         :integer
#  name             :string
#  description      :text
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require "rails_helper"

RSpec.describe PreeventItem, type: :model do
  it { is_expected.to validate_presence_of(:name) }

end
