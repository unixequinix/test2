# == Schema Information
#
# Table name: claim_parameters
#
#  id           :integer          not null, primary key
#  value        :string           default(""), not null
#  claim_id     :integer          not null
#  parameter_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe ClaimParameter, type: :model do
  describe 'for_category' do
    it 'should return the event and the parameters for a category' do
      claim_parameter = create(:claim_parameter)
      category = claim_parameter.parameter.category
      event = claim_parameter.claim.gtag.event
      expect(ClaimParameter.for_category(category, event)).not_to be_nil
    end
  end
end
