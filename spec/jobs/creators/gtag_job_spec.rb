require 'rails_helper'

RSpec.describe Creators::GtagJob, type: :job do
  let(:worker) { Creators::GtagJob }
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let!(:gtag) { create(:gtag, tag_uid: SecureRandom.hex(6), event: event) }
  let(:uid) { SecureRandom.hex(6) }
  let!(:balance) { rand(100) }

  context "creating gtags" do
    it "can create a gtag" do
      expect { worker.perform_now(event, SecureRandom.hex(6)) }.to change { event.gtags.count }.by(1)
    end
    it "cannot create a gtag with existing tag_uid" do
      expect { worker.perform_now(event, gtag.tag_uid) }.not_to change(Gtag, :count)
    end
    it "cannot create a gtag with empty uid" do
      expect { worker.perform_now(event, nil) }.not_to change(Gtag, :count)
    end
  end

  context "associating gtag and customer" do
    it "can connect the gtag with cusomter" do
      expect { worker.perform_now(event, uid, balance) }.to(change { event.gtags.count }.by(1)) && change { event.customers.count }.by(1)
    end
    it "can create a order" do
      expect { worker.perform_now(event, uid, balance) }.to change(Order, :count).by(1)
    end
    it "cannot create a order" do
      balance = 0
      expect { worker.perform_now(event, uid, balance) }.not_to change(Order, :count)
    end
  end
end
