require "rails_helper"

RSpec.describe Gtag, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let!(:station) { create(:station, event: event, category: "customer_portal") }

  subject { create(:gtag, event: event, customer: customer) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "upcases uid on save" do
    subject.tag_uid = "aaaaaaaaaaaaaa"
    subject.save
    expect(subject.tag_uid).to eql("AAAAAAAAAAAAAA")
  end

  it "simplifies looking for a customer with .assigned?" do
    expect(subject).to be_assigned
    subject.customer = nil
    expect(subject).not_to be_assigned
  end

  describe ".recalculate_balance" do
    context "with payments" do
      before do
        create_list(:poke, 3, customer_gtag: subject, credit: event.credit, credit_amount: 30, final_balance: 2)
        create_list(:poke, 3, customer_gtag: subject, credit: event.virtual_credit, credit_amount: 70, final_balance: 20)
      end

      it "changes the gtags credits" do
        expect { subject.recalculate_balance }.to change { subject.credits.to_f }.from(0.00).to(90)
      end

      it "changes the gtags virtual_credits" do
        expect { subject.recalculate_balance }.to change { subject.virtual_credits.to_f }.from(0.00).to(210)
      end

      it "changes the gtags final_balance" do
        expect { subject.recalculate_balance }.to change { subject.reload.final_balance.to_f }.from(0.00).to(2)
      end

      it "changes the gtags final_virtual_balance" do
        expect { subject.recalculate_balance }.to change { subject.reload.final_virtual_balance.to_f }.from(0.00).to(20)
      end

      it "sets consistent to the value of valid_balance?" do
        value = [true, false].sample
        allow(subject).to receive(:valid_balance?).and_return(value)
        expect { subject.recalculate_balance }.to change { subject.reload.consistent? }.to(value)
      end

      it "sets the value of complete to true if there are no counters" do
        subject.pokes_as_customer.update_all(gtag_counter: nil)
        expect { subject.recalculate_balance }.to change { subject.reload.complete? }.to(true)
      end

      it "sets the value of complete to true if all counters are present" do
        subject.pokes_as_customer.map.with_index { |p, counter| p.update!(gtag_counter: counter + 1) }
        expect { subject.recalculate_balance }.to change { subject.reload.complete? }.to(true)
      end

      it "sets the value of complete to false if any counter is missing" do
        subject.update!(complete: true)
        subject.pokes_as_customer.map.with_index { |p, counter| p.update!(gtag_counter: counter + 1) }
        subject.pokes_as_customer.sample.update!(gtag_counter: nil)
        expect { subject.recalculate_balance }.to change { subject.reload.complete? }.to(false)
      end
    end

    it "creates an alert if final_balance is negative" do
      allow(subject).to receive(:final_balance).and_return(-10)
      expect(Alert).to receive(:propagate).once
      subject.recalculate_balance
    end

    it "creates an alert if final_virtual_balance is negative" do
      allow(subject).to receive(:final_virtual_balance).and_return(-10)
      expect(Alert).to receive(:propagate).once
      subject.recalculate_balance
    end
  end
end
