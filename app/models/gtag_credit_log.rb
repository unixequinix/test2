# == Schema Information
#
# Table name: gtag_credit_logs
#
#  id         :integer          not null, primary key
#  gtag_id    :integer          not null
#  amount     :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GtagCreditLog < ActiveRecord::Base

  # Associations
  belongs_to :gtag

  validates :amount, presence: true

  def self.import_csv(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    gtag_credit_logs = []

    # Import Gtags
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      gtag_credit_log = new
      gtag_credit_log.attributes = row.to_hash.slice(*GtagCreditLog.attribute_names)
      gtag_credit_logs << gtag_credit_log
    end
    begin
      import gtag_credit_logs, validate: false
    rescue PG::Error => invalid
      @result << "Fila #{index}: " + invalid.record.errors.full_messages.join(". ")
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Spreadsheet.open(file.path, extension: :csv)
    when ".xls" then Roo::Spreadsheet.open(file.path, extension: :xls)
    when ".xlsx" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
