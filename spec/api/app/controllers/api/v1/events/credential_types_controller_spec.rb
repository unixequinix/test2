require "rails_helper"

RSpec.describe Api::V1::Events::CredentialTypesController, type: :controller do
  subject { Api::V1::Events::CredentialTypesController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'credential_type'" do
      expect(subject).to receive(:render_entities).with("credential_type").once
      subject.index
    end
  end
end
