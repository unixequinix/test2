RSpec.shared_examples "a credentiable" do
  it "sets credential_code to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.credential_code).not_to be_nil
    expect(stat.credential_code).to eql(credential.reference)
  end

  it "sets credential_type to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.credential_type).not_to be_nil
    expect(stat.credential_type).to eql(credential.credential_type)
  end

  it "sets purchaser_name to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.purchaser_name).to eql(credential.purchaser_full_name)
  end

  it "sets purchaser_email to that of credentiable" do
    stat = worker.perform_now(transaction.id)
    expect(stat.purchaser_email).to eql(credential.try(:purchaser_email))
  end
end
