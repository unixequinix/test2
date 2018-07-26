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
    it "calls set_memory" do
      access = build(:access, event: event)
      expect(access).to receive(:set_memory).once
      access.save
    end
  end

  describe ".recalculate_all_positions" do
    let(:access) { build(:access, event: event) }

    pending "decreases memory position for other accesses if change is from permanent to counter" do
      subject.save!
      access.save!
      expect { subject.update(mode: "permanent") && sleep(2) }.to change { access.reload.memory_position }.by(-1)
    end

    pending "increases memory position for other accesses if change is from counter to permanent" do
      access.save!
      subject.save!
      expect { access.update(mode: "counter") && sleep(2) }.to change { subject.reload.memory_position }.by(1)
    end

    it "does not allow the change if there is not enough space" do
      stub_const("Gtag::DEFINITIONS", ultralight_c: { entitlement_limit: 4, credential_limit: 32 })
      access.save!
      subject.save!
      access.mode = "counter"
      expect(access).not_to be_valid
    end
  end

  describe ".set_memory" do
    it "sets the subject memory_length to 2 if counter " do
      subject.update! mode: "counter"
      expect(subject.memory_length).to eq(2)
    end

    it "sets the subject memory_length to 1 if permanent " do
      subject.update! mode: %w[permanent permanent_strict].sample
      expect(subject.memory_length).to eq(1)
    end

    it "adds the next memory_position to the new access" do
      subject.save!
      access = create(:access, event: event)
      expect(access.memory_position).to eq(subject.memory_position + subject.memory_length)
    end
  end
end
