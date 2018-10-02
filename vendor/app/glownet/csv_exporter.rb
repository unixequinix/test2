class CsvExporter
  def self.sample(header, data)
    csv_file = CSV.generate(col_sep: ";") do |csv|
      csv << header
      data.each do |item|
        csv << item
      end
    end
    csv_file
  end

  def self.to_csv(objects, csv_options = {})
    items = [objects].flatten
    column_names = items.first&.attributes&.keys || []
    csv_file = CSV.generate(csv_options) do |csv|
      csv << column_names
      items.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
    csv_file
  end
end
