# == Schema Information
#
# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string
#  tag_serial_number :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#

class Gtag < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_many :gtag_registrations
  has_one :assigned_gtag_registration, ->{ where(aasm_state: :assigned) }, class_name: "GtagRegistration"
  has_many :customers, through: :gtag_registrations
  has_one :assigned_customer, ->{ where(gtag_registrations: {aasm_state: :assigned}) }, class_name: "Customer"

  # Validations
  validates :tag_uid, :tag_serial_number, presence: true
  validates_uniqueness_of :tag_uid, scope: :tag_serial_number

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |gtag|
        csv << gtag.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      gtag = find_by_id(row["id"]) || new
      gtag.attributes = row.to_hash.slice(*Gtag.attribute_names)
      gtag.save!
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
