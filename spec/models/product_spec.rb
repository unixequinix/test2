# == Schema Information
#
# Table name: products
#
#  description :string
#  is_alcohol  :boolean          default(FALSE)
#  name        :string
#  vat         :float            default(0.0)
#
# Indexes
#
#  index_products_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_ab0be0bcf2  (event_id => events.id)
#

require "spec_helper"

RSpec.describe Product, type: :model do
  it "has a valid factory" do
    expect(build(:product)).to be_valid
  end
end
