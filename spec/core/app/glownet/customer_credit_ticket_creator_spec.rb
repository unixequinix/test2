require "rails_helper"

RSpec.describe CustomerCreditTicketCreator, type: :domain_logic do
  let(:credential_assignment) { create(:credential_assignment_t_a) }

  context "when assigning" do
    let(:ticket) { credential_assignment.credentiable }
    it "creates a customer credit for every ticket credit" do
      expect do
        CustomerCreditTicketCreator.new.assign(ticket)
      end.to change(CustomerCredit, :count).by(ticket.credits.count)
    end

    it "foo" do
      CustomerCreditTicketCreator.new.assign(ticket)
      expect(CustomerCredit.all.count).to eq(1)
      customer_credit = CustomerCredit.first
      expect(customer_credit.amount).to eq(2)
      expect(customer_credit.refundable_amount).to eq(2)
      expect(customer_credit.final_balance).to eq(2)
      expect(customer_credit.final_refundable_balance).to eq(2)
    end
  end

  describe ".unassign" do
    it "should create a customer credit when a ticket is unassigned" do
      ticket = credential_assignment.credentiable
      CustomerCreditTicketCreator.new.assign(ticket)
      CustomerCreditTicketCreator.new.unassign(ticket)

      expect(CustomerCredit.all.count).to eq(2)
      customer_credit = CustomerCredit.order(created_in_origin_at: :asc).last
      expect(customer_credit.amount).to eq(-2)
      expect(customer_credit.refundable_amount).to eq(-2)
      expect(customer_credit.final_balance).to eq(0)
      expect(customer_credit.final_refundable_balance).to eq(0)
    end
  end
end
