require "rails_helper"

RSpec.describe Csv::CsvExporter do

  before do
    5.times do
      FactoryGirl.create(:refund)
    end
    @csv_file = Csv::CsvExporter.to_csv(Refund.all)
  end

  describe "the CSV file" do
    it "should have the attributes included in the headers" do
      csv_headers = get_headers_from_csv_file(@csv_file)
      expect(included_in?(csv_headers, Refund.attribute_names)).to be(true)
    end

    it "should have the same rows as records in DB +1 (for the headers)" do
      expect(number_of_records_in_csv(@csv_file)).to be(Refund.count())
    end
  end

  private
  def get_headers_from_csv_file file
    file.split("\n").first.split(",")
  end

  def included_in? contained, container
    (contained - container).empty?
  end

  def number_of_records_in_csv file
    file.count("\n") - 1 #remove headers
  end

end

