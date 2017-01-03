require "spec_helper"

RSpec.describe SonarDecoder, type: :domain_logic do
  let(:decoder) { SonarDecoder }
  let(:ticket_code) { "TC8B106BA990BDC56" }

  it "doesnt modify the original code variable" do
    decoder.decode(ticket_code)
    expect(ticket_code).to eq("TC8B106BA990BDC56")
  end
  %w(T34FCFF09B4651652 T4EF1864F836D35A7 T45038437B0D6FC54).each do |code|
    it "expects the code '#{code}' to decode correctly" do
      result = decoder.decode(code)
      expect(result).not_to be_nil
      expect(decoder.verify_prefix(result)).to eq(true)
    end
  end

  it ".valid_code? returns true if code is valid" do
    expect(decoder.valid_code?(ticket_code)).to be_truthy
  end

  it ".valid_code? returns false if code is not valid" do
    expect(decoder.valid_code?("FOoBAR123")).to be_falsey
  end

  it ".valid_code? returns false if code is nil" do
    expect(decoder.valid_code?(nil)).to be_falsey
  end

  it ".decode returns the ticket barcode decoded" do
    expect(decoder.decode(ticket_code)).to eq("201608504201012")
  end

  it ".perform returns nil if code is not valid" do
    expect(decoder.decode("NOTVALID")).to be_nil
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
