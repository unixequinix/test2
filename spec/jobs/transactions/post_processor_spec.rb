require "rails_helper"

RSpec.describe Transactions::PostProcessor, type: :job do
  let(:worker)  { Transactions::PostProcessor.new }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "12345678", event: event) }
  let(:customer) { create(:customer, event: event, anonymous: false) }
  let(:transaction) { create(:credit_transaction, event: event, customer_tag_uid: gtag.tag_uid) }

  describe "operator" do
    before { transaction.update! operator_tag_uid: "1234567890" }

    it "creates operator" do
      expect { worker.perform(transaction) }.to change { event.customers.where(operator: true).count }.by(1)
    end

    it "creates operator linked to gtag" do
      worker.perform(transaction)
      expect(event.customers.where(operator: true).last.active_gtag.tag_uid).to eq("1234567890")
    end

    it "creates operator gtag" do
      expect { worker.perform(transaction) }.to change { event.gtags.count }.by(1)
    end
  end

  describe ".resolve_customer" do
    let(:ticket) { create(:ticket, event: event, customer: create(:customer, event: event, anonymous: true)) }

    it "creates Alert if there are 2 different registered customers" do
      transaction.update! customer_id: customer.id
      gtag.update! customer: create(:customer, event: event, anonymous: false)
      expect(Alert).to receive(:propagate).once

      worker.perform(transaction)
    end

    it "does not create alert if both registered customers are the same" do
      transaction.update! customer_id: customer.id
      gtag.update! customer: customer
      expect(Alert).not_to receive(:propagate)

      worker.perform(transaction)
    end

    it "will not create a new customer if none registered are present" do
      gtag.update! customer: create(:customer, event: event, anonymous: true)
      expect { worker.perform(transaction) }.to change { event.customers.count }.by(1)
    end

    it "will choose one anonymous customer if none registered are present" do
      gtag.update! customer: create(:customer, event: event, anonymous: true)
      customers = [gtag, ticket].map(&:customer)
      worker.perform(transaction)
      [gtag, ticket].each { |credential| expect(customers).to include(credential.customer) }
    end

    it "deletes anonymous customer if present" do
      gtag.update! customer: customer
    end

    it "if not present in neither, creates one" do
      transaction.update!(customer: nil)
      expect { worker.perform(transaction) }.to change { event.customers.count }.by(2)
      expect(gtag.reload.customer).not_to be_nil
    end

    it "if not present in gtag but present in transaction, uses transactions" do
      transaction.update! customer_id: customer.id
      expect { worker.perform(transaction) }.to change { gtag.reload.customer }.from(nil).to(customer)
    end

    it "if not present in transaction but present in gtag, uses gtags" do
      gtag.update! customer: customer
      expect { worker.perform(transaction) }.not_to change(gtag.reload, :customer)
      expect(transaction.reload.customer).to eql(customer)
    end

    it "adds gtags customer_id to transaction" do
      gtag.update! customer: customer
      expect { worker.perform(transaction) }.to change { transaction.reload.customer }.from(nil).to(customer)
    end

    it "assigns any customer to the gtag not matter what" do
      expect { worker.perform(transaction) }.to change { gtag.reload.customer }.from(nil)
    end
  end

  describe ".assign_resources" do
    let(:ticket) { create(:ticket, event: event) }

    before { transaction.update!(ticket_code: ticket.code, action: "ticket_checkin") }

    it "does not use ticket_code to find ticket if action is gtag_replacement" do
      transaction.update(action: "gtag_replacement", ticket_code: gtag.tag_uid)
      expect { worker.perform(transaction) }.not_to raise_error
    end

    it "does not use ticket_code to find ticket if action is gtag_checkin" do
      transaction.update!(action: "gtag_checkin", ticket_code: gtag.tag_uid)
      expect { worker.perform(transaction) }.not_to raise_error
    end

    it "does not update the gtag if there is profile fraud" do
      gtag.update!(customer: customer)
      transaction.update!(customer: create(:customer, event: event, anonymous: false))
      expect { worker.perform(transaction) }.not_to change { gtag.reload.customer }.from(customer)
    end

    it "assigns a ticket to the transaction if found" do
      expect { worker.perform(transaction) }.to change { transaction.reload.ticket }.from(nil).to(ticket)
    end

    it "assigns a ticket to the transaction if action is ticket_validation" do
      transaction.update!(ticket_code: ticket.code, action: "ticket_validation")
      expect { worker.perform(transaction) }.to change { transaction.reload.ticket }.from(nil).to(ticket)
    end

    it "applies a customer to the ticket" do
      expect { worker.perform(transaction) }.to change { ticket.reload.customer }.from(nil)
    end

    it "assigns a gtag to the transaction" do
      expect { worker.perform(transaction) }.to change { transaction.reload.gtag }.from(nil).to(gtag)
    end

    it "applies a customer to the gtag" do
      expect { worker.perform(transaction) }.to change { gtag.reload.customer }.from(nil)
    end

    it "assign an order to the transaction if found" do
      order = customer.build_order([[10]])
      order.complete!
      transaction.update!(order_item_id: order.order_items.first.id, customer: customer)
      expect { worker.perform(transaction) }.to change { transaction.reload.order }.from(nil).to(order)
    end
  end

  describe ".decode_ticket" do
    let(:ctt_id) { "99" }
    let(:ticket_code) { "TE469A2F95B47623C" }

    before do
      @ctt = create(:ticket_type, event: event, company_code: ctt_id)
      @decoded_ticket = build(:ticket, event: event, code: ticket_code, ticket_type: @ctt)
      allow(SonarDecoder).to receive(:perform).and_return(ctt_id)
      transaction.update ticket_code: ticket_code, action: "ticket_checkin"
    end

    it "calls decode_ticket before not finding" do
      expect(worker).to receive(:decode_ticket).once.and_return(@decoded_ticket)
      worker.perform(transaction)
    end

    it "assigns a ticket to the transaction if its decoded" do
      @decoded_ticket.save!
      expect { worker.perform(transaction) }.to change { transaction.reload.ticket }.from(nil).to(@decoded_ticket)
    end

    it "attaches the correct ticket_type workerd on ticket_code" do
      expect(worker.decode_ticket(ticket_code, event).ticket_type).to eq(@ctt)
    end

    it "creates a ticket for the event" do
      expect { worker.decode_ticket(ticket_code, event) }.to change(Ticket, :count).by(1)
    end

    it "raises error if ticket is neither found nor decoded" do
      transaction.update ticket_code: "NOT_VALID_CODE"
      expect { worker.perform(transaction) }.to raise_error(RuntimeError)
    end
  end

  describe ".create_gtag" do
    before { transaction.update! operator_tag_uid: nil }

    it "does not create a Gtag when tag_uid is present in DB" do
      event.gtags << gtag
      expect { worker.perform(transaction) }.not_to change(Gtag, :count)
    end

    it "creates a Gtag for the event when tag_uid is not present in DB" do
      transaction.update! customer_tag_uid: "BBBBBBBBBBBBBB"
      expect { worker.perform(transaction) }.to change(Gtag, :count).by(1)
    end
  end

  describe "executing operations" do
    before { transaction.update!(action: "sale") }
    before { allow(Pokes::Sale).to receive(:perform_later) }

    it "executes tasks based on triggers" do
      Pokes::BalanceUpdater.inspect
      expect(Pokes::BalanceUpdater).to receive(:perform_later).once.with(transaction)
      worker.perform(transaction)
    end

    it "does not execute operations if status code is not 0" do
      transaction.update!(status_code: 2)
      expect(Pokes::BalanceUpdater).not_to receive(:perform_later)
      worker.perform(transaction)
    end
  end
end
