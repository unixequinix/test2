RSpec.shared_examples "a ticket_type" do
  it "sets ticket_type_id to that of credentiable" do
    poke = worker.perform_now(transaction)
    expect(poke.ticket_type_id).not_to be_nil
    expect(poke.ticket_type_id).to eql(credential.ticket_type_id)
  end

  it "sets company_id to that of credentiable" do
    poke = worker.perform_now(transaction)
    expect(poke.company_id).not_to be_nil
    expect(poke.company_id).to eql(credential.ticket_type.company_id)
  end
end
