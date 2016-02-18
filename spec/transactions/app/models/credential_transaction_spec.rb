require "rails_helper"

RSpec.describe CredentialTransaction, type: :model do
  let(:event) { build(:event) }
  let(:transaction) { build(:credential_transaction, event: event) }
end
