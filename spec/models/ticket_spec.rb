require 'rails_helper'

RSpec.describe Ticket, type: :model do

  it { is_expected.to validate_presence_of(:number) }

end
