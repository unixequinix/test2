require "spec_helper"

RSpec.describe TicketType, type: :model do
  subject { build(:ticket_type) }
  let(:event) { create(:event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".hide!" do
    it "changes the hidden value to true" do
      subject.save
      expect do
        subject.hide!
      end.to change(subject, :hidden).from(false).to(true)
    end
  end

  describe ".show!" do
    it "changes the hidden value to true" do
      subject.hidden = true
      subject.save
      expect do
        subject.show!
      end.to change(subject, :hidden).from(true).to(false)
    end
  end
end
