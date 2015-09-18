# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require "rails_helper"

RSpec.describe Entitlement, type: :model do
  it { is_expected.to validate_presence_of(:name) }
end
