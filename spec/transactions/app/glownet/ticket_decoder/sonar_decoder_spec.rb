require "rails_helper"

RSpec.describe TicketDecoder::SonarDecoder, type: :domain_logic do
  describe ".perform" do
    it "returns the ticket barcode decoded" do
      expect(TicketDecoder::SonarDecoder.perform("TC8B106BA990BDC56")).to eq("201608504201012")
    end
  end
end
