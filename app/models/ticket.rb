# == Schema Information
#
# Table name: tickets
#
#  id             :integer          not null, primary key
#  ticket_type_id :integer
#  number         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

class Ticket < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_many :admissions
  has_one :assigned_admission, ->{ where(aasm_state: :assigned) }, class_name: "Admission"
  has_many :customers, through: :admissions
  has_one :assigned_customer, ->{ where(admissions: {aasm_state: :assigned}) }, class_name: "Customer"
  belongs_to :ticket_type

  # Validations
  validates :number, presence: true, uniqueness: true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |ticket|
        csv << ticket.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      ticket = find_by_id(row["id"]) || new
      ticket.attributes = row.to_hash.slice(*Ticket.attribute_names)
      ticket.save!
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
