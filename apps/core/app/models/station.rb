# == Schema Information
#
# Table name: stations
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#

class Station < ActiveRecord::Base
end
