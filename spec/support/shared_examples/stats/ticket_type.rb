RSpec.shared_examples "a ticket_type" do
  it "sets ticket_type_id to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.ticket_type_id).not_to be_nil
    expect(stat.ticket_type_id).to eql(credential.ticket_type_id)
  end

  it "sets ticket_type_name to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.ticket_type_name).not_to be_nil
    expect(stat.ticket_type_name).to eql(credential.ticket_type.name)
  end

  it "sets company_id to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.company_id).not_to be_nil
    expect(stat.company_id).to eql(credential.ticket_type.company_id)
  end

  it "sets company_name to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.company_name).not_to be_nil
    expect(stat.company_name).to eql(credential.ticket_type.company.name)
  end
end
