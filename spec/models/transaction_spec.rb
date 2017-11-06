require "rails_helper"

RSpec.describe Transaction, type: :model do
  let(:klass) { Transaction }
  subject { build(:transaction) }

  describe ".category" do
    it "returns the category name downcased" do
      subject.type = "AccessTransaction"
      expect(subject.category).to eq("access")
    end
  end

  describe ".class_for_type" do
    it "returns the class based on the transaction type" do
      expect(klass.class_for_type("access")).to eq(AccessTransaction)
      expect(klass.class_for_type("credit")).to eq(CreditTransaction)
    end
  end

  describe ".description" do
    it "returns the category and type humanized" do
      allow(subject).to receive(:category).and_return("Glownet")
      subject.action = "Test"
      expect(subject.description).to eq("Glownet: Test")
    end
  end

  describe ".mandatory_fields" do
    fields = %w[action customer_tag_uid operator_tag_uid device_uid device_db_index device_created_at status_code status_message]

    fields.each do |field|
      it "validates '#{field}' field" do
        expect(klass.mandatory_fields).to include(field)
      end
    end
  end
end
