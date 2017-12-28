require "rails_helper"

RSpec.describe Access, type: :model do
  let(:event) { create(:event) }
  subject { build(:access, mode: "counter", event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe ".infinite?" do
    it "false for 'counter'" do
      allow(subject).to receive(:mode).and_return("counter")
      expect(subject.infinite?).to eq(false)
    end

    it "true for 'permanent'" do
      allow(subject).to receive(:mode).and_return("permanent")
      expect(subject.infinite?).to eq(true)
    end

    it "true for 'permanent_strict'" do
      allow(subject).to receive(:mode).and_return("permanent_strict")
      expect(subject.infinite?).to eq(true)
    end
  end

  context "before validations" do
    describe ".position " do
      it "adds the next memory_position to the new subject" do
        subject.save!
        access = create(:access, event: event)
        expect(access.memory_position).to eq(subject.memory_position + subject.memory_length)
      end
    end
  end

  describe ".set_memory_length" do
    it "sets the subject memory_length to 2 if counter " do
      subject.update! mode: "counter"
      expect(subject.memory_length).to eq(2)
    end

    it "sets the subject memory_length to 1 if permanent " do
      subject.update! mode: %w[permanent permanent_strict].sample
      expect(subject.memory_length).to eq(1)
    end
  end
end
