require "rails_helper"

RSpec.describe Api::V1::Events::ProductsController, type: :controller do
  subject { Api::V1::Events::ProductsController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'product'" do
      expect(subject).to receive(:render_entities).with("product").once
      subject.index
    end
  end
end
