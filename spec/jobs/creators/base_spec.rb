require 'rails_helper'

RSpec.describe Creators::Base, type: :job do
  let(:worker) { Creators::Base.new }
  let(:old_event) { create(:event) }
  let(:new_event) { create(:event) }
  let(:old_customer) { create(:customer, event: old_event, anonymous: false) }

  context "copying customer" do
    it "can copy customer" do
      expect { worker.send(:copy_customer, old_customer, new_event) }.to change { new_event.customers.count }.by(1)
    end
  end
  context "creating gtag" do
    it "can create a gtag" do
      expect { worker.send(:create_gtag, SecureRandom.hex(6), new_event) }.to change { new_event.gtags.count }.by(1)
    end
  end
end
