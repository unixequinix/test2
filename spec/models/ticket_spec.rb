require "spec_helper"

RSpec.describe Ticket, type: :model do
  subject { build(:ticket) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
