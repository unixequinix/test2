class Csv::CsvExporter
  # Ticket Type
  def self.to_csv(items_and_extra_columns, csv_options = {})
    if items_and_extra_columns.first.class != items_and_extra_columns.second.class
      items, headers, extra_columns = items_and_extra_columns
    else
      items = items_and_extra_columns
    end
    column_names = items.first.attributes.keys
    csv_file = CSV.generate(csv_options) do |csv|
      csv << column_names
      items.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
    if extra_columns
      csv_file = attach_columns_to_csv(csv_file, headers, extra_columns).join
    else
      csv_file
    end
  end

  def self.attach_columns_to_csv(csv_file, headers, extra_columns)
    csv_file.split("\n").to_enum.with_index.map do |row, index|
      if (index == 0)
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
