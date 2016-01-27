require 'rails_helper'

RSpec.describe EventLog, type: :model do
  let(:log) { build(:event_log) }

  context "writing" do
    it "should create an appropiate class of log depending on type" do
      expect(EventLog.write "access_log", {}).to be_a_kind_of(AccessLog)
    end

    it "should include the parameters passed" do
      result = EventLog.write "monetary_log", amount: 2.2
      expect(result.amount).to eq(2.2)
    end

    it "should save the record" do
      result = EventLog.write "access_log", {}
      expect(result).not_to be_new_record
      expect(result).to be_a_kind_of(AccessLog)
    end

    it "should be able to delay the job" do
      arguments = ["monetary_log", amount: rand(10)]
      EventLog.delay.write arguments
      expect(EventLog.method :write).to be_delayed(arguments)
    end
  end

  it "requires a type" do
    expect(log).to_not be_nil
  end
end
