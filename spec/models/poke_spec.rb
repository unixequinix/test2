require "rails_helper"

RSpec.describe Poke, type: :model do
  subject { create(:poke, :as_topups, event: create(:event)) }

  describe "check json returned value" do
    before(:each) do
      create(:station, category: 'top_up_refund')
    end

    context "should return money recon" do
      it "should have correct money values" do
        json = JSON.parse(subject.event.pokes.money_recon.to_json)
        expect(json.map { |i| i['money'].to_f }.sum).to eq(subject.monetary_total_price.to_f)
      end
    end
  end
end
