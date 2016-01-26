require 'rails_helper'

RSpec.describe AccessLog, type: :model do
  let(:log) { build(:access_log) }

  it "requires a type" do
    expect(log).to_not be_nil
  end
end
