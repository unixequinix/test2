# == Schema Information
#
# Table name: ticket_types
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  company         :string           not null
#  credit          :decimal(8, 2)    default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  simplified_name :string
#

class TicketType < ActiveRecord::Base
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  has_many :tickets, dependent: :restrict_with_error
  has_many :entitlement_ticket_types, dependent: :destroy
  has_many :entitlements, through: :entitlement_ticket_types

  accepts_nested_attributes_for :entitlements

  # Validations
  validates :name, :company, :credit, presence: true

  # Scopes
  scope :companies, -> { uniq.pluck(:company) }

  # Select options with all the entitlements
  def self.form_selector
    all.map { |ticket_type| [ticket_type.name, ticket_type.id] }
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |ticket_types|
        csv << ticket_types.attributes.values_at(*column_names)
      end
    end
  end

  def self.import_csv(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)

    # Import Ticket Types
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      ticket_type = find_by_id(row['id']) || new
      ticket_type.attributes = row.to_hash.slice(*TicketType.attribute_names)
      ticket_type.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::Spreadsheet.open(file.path, extension: :csv)
    when '.xls' then Roo::Spreadsheet.open(file.path, extension: :xls)
    when '.xlsx' then Roo::Spreadsheet.open(file.path, extension: :xlsx)
    else fail "Unknown file type: #{file.original_filename}"
    end
  end
end
