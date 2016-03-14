require "spec_helper"

RSpec.describe TicketDecoder::SonarDecoder, type: :domain_logic do
  let(:decoder) { TicketDecoder::SonarDecoder }
  let(:ticket_code) { "TC8B106BA990BDC56" }

  it ".decode returns the ticket barcode decoded" do
    expect(decoder.decode(ticket_code)).to eq(201_608_504_201_012)
  end

  it ".perform returns nil if code is not valid" do
    expect(decoder.decode("NOTVALID")).to eq(nil)
  end

  describe ".verify_prefix" do
    it "returns true if the code starts with 2016" do
      expect(decoder.verify_prefix("201612313")).to eq(true)
    end

    it "returns false if the code does not start with 2016" do
      expect(decoder.verify_prefix("200012313")).to eq(false)
    end
  end

  it ".reverse_hex reveses a string in groups of 2" do
    expect(decoder.reverse_hex("AABB")).to eq("BBAA")
  end

  it ".perform returns the company_ticket_code form the encoded string" do
    expect(decoder.perform(ticket_code)).to eq(12)
  end
end
