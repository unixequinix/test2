# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require "rails_helper"

RSpec.describe Credit, type: :model do
  it "should return the price of the preevent_product attached to the standard credit" do
    credit = create(:credit)
    expect(@event.total_credits.to_f).to be(29.97)
  end
end
