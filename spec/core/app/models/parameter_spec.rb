# == Schema Information
#
# Table name: parameters
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  data_type   :string           not null
#  category    :string           not null
#  group       :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Parameter, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:data_type) }
  it { is_expected.to validate_presence_of(:category) }

  describe 'default_value_for' do
    it "should get '' as default value for a Parameter with data_type nil" do
      data_type = nil
      expect(Parameter.default_value_for(data_type)).to eq('')
    end

    it 'should get default value for a Parameter with a data_type' do
      data_type = 'string'
      expect(Parameter.default_value_for(data_type)).to eq('-')

      data_type = 'currency'
      expect(Parameter.default_value_for(data_type)).to eq('0.0')

      data_type = 'integer'
      expect(Parameter.default_value_for(data_type)).to eq('0')
    end
  end
end
