require "spec_helper"

RSpec.describe TicketDecoder::SonarDecoder, type: :domain_logic do
  describe ".perform" do
    it "returns the ticket barcode decoded" do
      expect(TicketDecoder::SonarDecoder.perform("TC8B106BA990BDC56")).to eq(201_608_504_201_012)
    end
  end
end
