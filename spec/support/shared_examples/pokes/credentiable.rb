RSpec.shared_examples "a credentiable" do
  it "sets credential_id to that of credentiable" do
    poke = worker.perform_now(transaction)

    if credential.is_a?(Ticket)
      expect(poke.ticket_id).not_to be_nil
      expect(poke.ticket).to eql(credential)
    else
      expect(poke.ticket_id).to be_nil
      expect(poke.customer_gtag_id).not_to be_nil
    end
  end
end
