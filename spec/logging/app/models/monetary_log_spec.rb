require 'rails_helper'

RSpec.describe MonetaryLog, type: :model do
  let(:log) { build(:monetary_log) }

  it "requires a type" do
    expect(log).to_not be_nil
  end
end
