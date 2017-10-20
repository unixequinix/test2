RSpec.shared_examples "a stat" do
  before do
    @action = action
    @name = name
  end

  it "works" do
    expect { worker.perform_now(transaction.id) }.to change(Stat, :count).by(1)
  end

  it "creates only 1 if already present" do
    worker.perform_now(transaction.id)
    expect { worker.perform_now(transaction.id) }.not_to change(Stat, :count)
  end

  it "sets action to #{@action}" do
    stat = worker.perform_now(transaction.id)
    expect(stat.action).to eql(@action)
  end

  it "sets name to #{@name}" do
    stat = worker.perform_now(transaction.id)
    expect(stat.name).to eql(@name)
  end
end
