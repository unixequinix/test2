require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:total) }
  it { is_expected.to validate_presence_of(:aasm_state) }
end