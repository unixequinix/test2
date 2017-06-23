require "spec_helper"

RSpec.describe Ticket, type: :model do
  let(:event) { build(:event) }
  let(:customer) { build(:customer, event: event) }
  subject { build(:ticket, customer: customer, event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
