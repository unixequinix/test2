RSpec.shared_examples "a money" do
  it "sets monetary_quantity to 1" do
    stat = worker.perform_now(transaction.id)
    expect(stat.monetary_quantity).to eql(1)
  end

  it "sets monetary_total_price to transaction price" do
    stat = worker.perform_now(transaction.id)
    expect(stat.monetary_total_price).to eql(transaction.price)
  end

  it "sets monetary_unit_price to transaction price" do
    stat = worker.perform_now(transaction.id)
    expect(stat.monetary_unit_price).to eql(transaction.price)
  end
end
