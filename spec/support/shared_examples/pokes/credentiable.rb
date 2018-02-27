RSpec.shared_examples "a credentiable" do
  it "sets credential_id to that of credentiable" do
    poke = worker.perform_now(transaction)
    expect(poke.credential_id).not_to be_nil
    expect(poke.credential_id).to eql(credential.id)
  end

  it "sets credential_type to that of credentiable" do
    poke = worker.perform_now(transaction)
    expect(poke.credential_type).not_to be_nil
    expect(poke.credential_type).to eql(credential.class.to_s)
  end
end
