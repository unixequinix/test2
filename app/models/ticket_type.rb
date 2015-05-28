# == Schema Information
#
# Table name: ticket_types
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  company    :string           not null
#  credit     :decimal(8, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class TicketType < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_many :entitlement_ticket_types, dependent: :restrict_with_error
  has_many :entitlements, through: :entitlement_ticket_types, dependent: :restrict_with_error

  accepts_nested_attributes_for :entitlements

  # Validations
  validates :name, :company, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |ticket_type| [ticket_type.name, ticket_type.id] }
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
    ticket_types = []

    # Import Tickets
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      # ticket_type = find_by_id(row["id"]) || new
      ticket_type = new
      ticket_type.attributes = row.to_hash.slice(*Ticket.attribute_names)
      # if row["ticket_type"]
      #  ticket_type = TicketType.where(name: row["ticket_type"], company: row["company"]).first
      #  assignation_ticket_type = ticket_type.nil? ? TicketType.create(name: row["ticket_type"], credit: row["credit"], company: row["company"]) : ticket_type
      #  ticket.ticket_type = assignation_ticket_type if ticket.ticket_type.nil?
      #end
      ticket_types << ticket_type
    end
    begin
      import tickets, validate: false
    rescue PG::UniqueViolation => invalid
      @result << "Fila #{index}: " + invalid.record.errors.full_messages.join(". ")
    end
  end

end
