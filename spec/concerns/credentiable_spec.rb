require 'rails_helper'

shared_examples_for "credentiable" do
  let(:model) { described_class } # the class that includes the concern
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  subject { create(model.to_s.underscore.to_sym, event: event) }

  describe ".assign_customer" do
    context "subject has customer_id assigned as anonimous customer" do
      it "assigns the customer to the #{described_class}" do
        expect do
          subject.assign_customer(customer)
          subject.reload
        end.to change(subject, :customer).from(subject.customer_id).to(customer)
      end
    end

    context "subject has not customer_id assigned" do
      it "assigns the customer to the #{described_class}" do
        expect do
          subject.assign_customer(customer)
          subject.reload
        end.to change(subject, :customer).from(nil).to(customer)
      end

      it "touches the customer updated_at" do
        customer.update_columns(updated_at: 100.years.ago)
        expect { subject.assign_customer(customer) }.to change(customer, :updated_at)
      end

      it "touches the customer updated_at" do
        customer.update_columns(updated_at: 100.years.ago)
        expect { subject.assign_customer(customer) }.to change(customer, :updated_at)
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
  end
end

RSpec.describe Gtag, type: :model do
  it_behaves_like "credentiable"
end

RSpec.describe Ticket, type: :model do
  it_behaves_like "credentiable"
end
