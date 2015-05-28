# == Schema Information
#
# Table name: tickets
#
#  id             :integer          not null, primary key
#  ticket_type_id :integer
#  number         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  purchaser_id   :integer
#

require 'rails_helper'

RSpec.describe Ticket, type: :model do

  it { is_expected.to validate_presence_of(:number) }

end
