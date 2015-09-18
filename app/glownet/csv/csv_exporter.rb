class Csv::CsvExporter

  #Ticket Type
  def self.to_csv(items, extra_columns = [] ,csv_options = {})
    column_names = items.first.attributes.keys
    CSV.generate(csv_options) do |csv|
      csv << column_names
      items.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end

end