# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Company, type: :model do
end
