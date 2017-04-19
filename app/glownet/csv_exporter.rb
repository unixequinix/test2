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

  def self.attach_columns_to_csv(csv_file, headers, extra_columns)
    csv_file.split("\n").to_enum.with_index.map do |row, index|
      if index.zero?
        row + "," + headers.join(",") + "\n"
      else
        new_row_to_add = headers.reduce("") do |new_row, key|
          new_row += ","
          new_row + (extra_columns[index][key] || "")
        end
        row + new_row_to_add + "\n"
      end
    end
  end
end
