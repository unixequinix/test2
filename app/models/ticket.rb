# == Schema Information
#
# Table name: tickets
#
#  id                :integer          not null, primary key
#  ticket_type_id    :integer          not null
#  number            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  purchaser_email   :string
#  purchaser_name    :string
#  purchaser_surname :string
#

class Ticket < ActiveRecord::Base
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  has_many :admittances, dependent: :restrict_with_error
  has_one :assigned_admittance,
          -> { where(aasm_state: :assigned) },
          class_name: 'Admittance'
  has_many :customers, through: :admittances
  has_one :assigned_customer,
          -> { where(admissions: { aasm_state: :assigned }) },
          class_name: 'Customer'
  belongs_to :ticket_type
  has_many :comments, as: :commentable

  # Validations
  validates :number, :ticket_type, presence: true
  validates :number, uniqueness: true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |ticket|
        csv << ticket.attributes.values_at(*column_names)
      end
    end
  end

  def self.import_csv(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    tickets = []

    # Import Tickets
    ticket_types = Hash[TicketType.form_selector]
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      ticket = new
      ticket.attributes = row.to_hash.slice(*Ticket.attribute_names)
      if row['ticket_type']
        ticket.ticket_type_id = ticket_types[row['ticket_type']]
      end
      tickets << ticket
    end
    begin
      import tickets, validate: false
    rescue PG::Error => invalid
      @result << "Fila #{index}: " +
        invalid.record.errors.full_messages.join('. ')
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::Spreadsheet.open(file.path,
      extension: :csv, csv_options: { encoding: Encoding::ISO_8859_1 })
    when '.xls' then Roo::Spreadsheet.open(file.path, extension: :xls)
    when '.xlsx' then Roo::Spreadsheet.open(file.path, extension: :xlsx)
    else fail "Unknown file type: #{file.original_filename}"
    end
  end
end
