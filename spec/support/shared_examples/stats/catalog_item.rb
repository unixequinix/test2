RSpec.shared_examples "a catalog_item" do
  it "sets catalog_item_id correctly" do
    stat = worker.perform_now(transaction.id)
    expect(stat.catalog_item_id).not_to be_nil
    expect(stat.catalog_item_id).to eql(catalog_item.id)
  end

  it "sets catalog_item_name correctly" do
    stat = worker.perform_now(transaction.id)
    expect(stat.catalog_item_name).not_to be_nil
    expect(stat.catalog_item_name).to eql(catalog_item.name)
  end

  it "sets catalog_item_type correctly" do
    stat = worker.perform_now(transaction.id)
    expect(stat.catalog_item_type).not_to be_nil
    expect(stat.catalog_item_type).to eql(catalog_item.class.to_s)
  end
end
