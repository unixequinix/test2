require 'spec_helper'

shared_examples_for "credentiable" do
  let(:model) { described_class } # the class that includes the concern
  let(:customer) { create(:customer) }

  subject { create(model.to_s.underscore.to_sym) }

  describe ".assign_customer" do
    it "assigns the customer to the #{described_class}" do
      expect { subject.assign_customer(customer, :test, nil) }.to change(subject, :customer).from(nil).to(customer)
    end

    it "touches the customer updated_at" do
      customer.update_columns(updated_at: 100.years.ago)
      expect { subject.assign_customer(customer, :test, nil) }.to change(customer, :updated_at)
    end

    it "touches the customer updated_at" do
      customer.update_columns(updated_at: 100.years.ago)
      expect { subject.assign_customer(customer, :test, nil) }.to change(customer, :updated_at)
    end

    it "writes the transaction" do
      expect(subject).to receive(:write_assignation_transaction).with("assigned", :test, nil)
      subject.assign_customer(customer, :test, nil)
    end
  end

  describe ".unassign_customer" do
    before { subject.update!(customer: customer) }

    it "unassigns the customer" do
      expect { subject.unassign_customer(:test, nil) }.to change(subject, :customer).from(customer).to(nil)
    end

    it "touches the customer updated_at" do
      customer.update_columns(updated_at: 100.years.ago)
      expect { subject.unassign_customer(:test, nil) }.to change(customer, :updated_at)
    end

    it "touches the customer updated_at" do
      customer.update_columns(updated_at: 100.years.ago)
      expect { subject.unassign_customer(:test, nil) }.to change(customer, :updated_at)
    end

    it "writes the transaction" do
      expect(subject).to receive(:write_assignation_transaction).with("unassigned", :test, nil)
      subject.unassign_customer(:test, nil)
    end
  end

  describe ".write_assignation_transaction" do
    before { subject.update!(customer: customer) }

    it "writes a credential transaction" do
      expect { subject.write_assignation_transaction("assigned", :test, nil) }.to change(CredentialTransaction, :count).by(1)
    end

    it "resolves the action to #{described_class}_action" do
      transaction = subject.write_assignation_transaction("assigned", :test, nil)
      expect(transaction.action).to eq("#{model.to_s.underscore}_assigned")
    end

    it "call CredentialTransaction.write! method" do
      action = "#{model.to_s.underscore}_assigned"
      expect(CredentialTransaction).to receive(:write!).with(subject.event, action, :test, customer, nil, subject.assignation_atts)
      subject.write_assignation_transaction("assigned", :test, nil)
    end
  end
end

RSpec.describe Gtag, type: :model do
  it_behaves_like "credentiable"
end

RSpec.describe Ticket, type: :model do
  it_behaves_like "credentiable"
end
