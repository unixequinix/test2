RSpec.shared_examples "a credit" do
  let(:t_event) { transaction.event }

  it "sets credit_amount to one of transaction" do
    stat = worker.perform_now(transaction.id)
    expect(stat.credit_amount).to eql(transaction.credits)
  end

  it "sets credit_id to one of event" do
    stat = worker.perform_now(transaction.id)
    expect(stat.credit_id).to eql(t_event.credit.id)
  end

  it "sets credit_name to one of event" do
    stat = worker.perform_now(transaction.id)
    expect(stat.credit_name).to eql(t_event.credit.name)
  end

  it "sets credit_value to one of event" do
    stat = worker.perform_now(transaction.id)
    expect(stat.credit_value).to eql(t_event.credit.value)
  end
end
