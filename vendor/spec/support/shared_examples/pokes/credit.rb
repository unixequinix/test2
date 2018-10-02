RSpec.shared_examples "a credit" do
  let(:t_event) { transaction.event }

  before { @poke = [worker.perform_now(transaction)].flatten.first }

  it "sets credit_id to one of event" do
    expect(@poke.credit_id).to eql(t_event.credit.id)
  end
end
