require 'rails_helper'

shared_examples_for "credentiable" do
  let(:model) { described_class } # the class that includes the concern
  let(:customer) { create(:customer) }

  subject { create(model.to_s.underscore.to_sym) }

  describe ".assign_customer" do
    context "subject has customer_id assigned as anonimous customer" do
      it "assigns the customer to the #{described_class}" do
        expect do
          subject.assign_customer(customer, nil)
          subject.reload
        end.to change(subject, :customer).from(subject.customer_id).to(customer)
      end
    end

    context "subject has not customer_id assigned" do
      it "assigns the customer to the #{described_class}" do
        expect do
          subject.assign_customer(customer, nil)
          subject.reload
        end.to change(subject, :customer).from(nil).to(customer)
      end

      it "touches the customer updated_at" do
        customer.update_columns(updated_at: 100.years.ago)
        expect { subject.assign_customer(customer, nil) }.to change(customer, :updated_at)
      end

      it "touches the customer updated_at" do
        customer.update_columns(updated_at: 100.years.ago)
        expect { subject.assign_customer(customer, nil) }.to change(customer, :updated_at)
      end

      it "writes the transaction" do
        expect(subject).to receive(:write_assignation_transaction).with("assigned", nil, :portal)
        subject.assign_customer(customer, nil)
      end
    end
  end

  describe ".unassign_customer" do
    before { subject.update!(customer: customer) }

    it "unassigns the customer" do
      expect { subject.unassign_customer }.to change(subject, :customer).from(customer).to(nil)
    end

    it "touches the customer updated_at" do
      customer.update_columns(updated_at: 100.years.ago)
      expect { subject.unassign_customer }.to change(customer, :updated_at)
    end

    it "touches the customer updated_at" do
      customer.update_columns(updated_at: 100.years.ago)
      expect { subject.unassign_customer }.to change(customer, :updated_at)
    end

    it "writes the transaction" do
      expect(subject).to receive(:write_assignation_transaction).with("unassigned", nil, :portal)
      subject.unassign_customer
    end
  end

  describe ".write_assignation_transaction" do
    before { subject.update!(customer: customer) }

    it "writes a credential transaction" do
      expect { subject.write_assignation_transaction("assigned", nil) }.to change(CredentialTransaction, :count).by(1)
    end

    it "resolves the action to #{described_class}_action" do
      transaction = subject.write_assignation_transaction("assigned", nil)
      expect(transaction.action).to eq("#{model.to_s.underscore}_assigned")
    end

    it "call CredentialTransaction.write! method" do
      action = "#{model.to_s.underscore}_assigned"
      expect(CredentialTransaction).to receive(:write!).with(subject.event, action, :portal, customer, nil, subject.assignation_atts)
      subject.write_assignation_transaction("assigned", nil)
    end
  end
end

RSpec.describe Gtag, type: :model do
  it_behaves_like "credentiable"
end

RSpec.describe Ticket, type: :model do
  it_behaves_like "credentiable"
end
