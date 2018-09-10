RSpec.shared_examples "a catalog_item" do
  it "sets catalog_item_id correctly" do
    poke = worker.perform_now(transaction)
    expect(poke.catalog_item_id).not_to be_nil
    expect(poke.catalog_item_id).to eql(catalog_item.id)
  end

  it "sets catalog_item_type correctly" do
    poke = worker.perform_now(transaction)
    expect(poke.catalog_item_type).not_to be_nil
    expect(poke.catalog_item_type).to eql(catalog_item.class.to_s)
  end
end
