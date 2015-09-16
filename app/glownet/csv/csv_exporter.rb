class Csv::CsvExporter

  #Ticket Type
  def self.to_csv(items, options = {})
    column_names = items.first.attributes.keys
    CSV.generate(options) do |csv|
      csv << column_names
      items.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end

end