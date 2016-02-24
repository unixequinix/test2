# == Schema Information
#
# Table name: stations
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  event_id        :integer          not null
#  station_type_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Station < ActiveRecord::Base
end
