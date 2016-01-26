require 'rails_helper'

RSpec.describe CredentialLog, type: :model do
  let(:log) { build(:credential_log) }

  it "requires a type" do
    expect(log).to_not be_nil
  end
end
