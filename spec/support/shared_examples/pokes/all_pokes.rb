RSpec.shared_examples "a poke" do
  before do
    @action = action
    @description = name
  end

  it "works" do
    expect { worker.perform_now(transaction) }.to change(Poke, :count).by(1)
  end

  it "creates only 1 if already present" do
    worker.perform_now(transaction)
    expect { worker.perform_now(transaction) }.not_to change(Poke, :count)
  end

  it "sets action to #{@action}" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.action).to eql(@action)
  end

  it "sets description to #{@description}" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.description).to eql(@description)
  end

  it "sets operation_id to transactions id" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.operation_id).to eql(transaction.id)
  end

  it "sets source to onsite if transaction_origin is onsite" do
    transaction.update!(transaction_origin: "onsite")
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.source).to eql("onsite")
  end

  it "sets source to online if transaction_origin is customer_portal" do
    transaction.update!(transaction_origin: "customer_portal")
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.source).to eql("online")
  end

  it "sets source to online if transaction_origin is admin_panel" do
    transaction.update!(transaction_origin: "admin_panel")
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.source).to eql("online")
  end

  it "sets source to online if transaction_origin is admin_panel" do
    transaction.update!(transaction_origin: "api")
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.source).to eql("online")
  end

  it "sets source to unknown if transaction_origin is anything else" do
    transaction.update!(transaction_origin: "foo")
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.source).to eql("unknown")
  end

  it "sets event_id to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.event_id).to eql(transaction.event_id)
  end

  it "sets station_id to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.station_id).to eql(transaction.station_id)
  end

  it "sets operator_id to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.operator_id).to eql(transaction.operator_id)
  end

  it "sets operator_gtag_id to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.operator_gtag_id).to eql(transaction.operator_gtag_id)
  end

  it "sets customer_id to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.customer_id).to eql(transaction.customer_id)
  end

  it "sets customer_gtag_id to transactions gtag_id" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.customer_gtag_id).to eql(transaction.gtag_id)
  end

  it "sets gtag_counter to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.gtag_counter).to eql(transaction.gtag_counter)
  end

  it "sets status_code to transactions" do
    poke = [worker.perform_now(transaction)].flatten.first
    expect(poke.status_code).to eql(transaction.status_code)
  end
end
