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
#  event_id          :integer          not null
#

class Gtag < ActiveRecord::Base

  STANDARD       = 'standard'
  CARD  = 'card'
  SIMPLE = 'simple'

  # Type of the gtags
  FORMATS = [STANDARD, CARD, SIMPLE]


  before_validation :upcase_gtag
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_many :gtag_registrations, dependent: :restrict_with_error
  has_one :assigned_gtag_registration, ->{ where(aasm_state: :assigned) }, class_name: "GtagRegistration"
  has_many :customer_event_profiles, through: :gtag_registrations
  has_one :assigned_customer_event_profile, ->{ where(gtag_registrations: {aasm_state: :assigned}) }, class_name: "CustomerEventProfile"
  has_one :gtag_credit_log
  has_one :refund
  has_many :claims
  has_one :completed_claim, ->{ where(aasm_state: :completed) }, class_name: "Claim"
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :gtag_credit_log, allow_destroy: true

  # Validations
  validates_uniqueness_of :tag_uid, scope: :event_id
  validates :tag_uid, :tag_serial_number, presence: true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      gtag_columns = column_names.clone
      gtag_columns << 'amount'
      csv << gtag_columns
      all.each do |gtag|
        attributes = gtag.attributes.values_at(*gtag_columns)
        attributes[-1] = gtag.gtag_credit_log.amount unless gtag.gtag_credit_log.nil?
        csv << attributes
      end
    end
  end

  def self.import_csv(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    gtags = []

    # Import Gtags
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      gtag = new
      gtag.attributes = row.to_hash.slice(*Gtag.attribute_names)
      gtag.tag_uid = gtag.tag_uid.upcase
      gtag.tag_serial_number = gtag.tag_serial_number.upcase
      gtags << gtag
    end
    begin
      import gtags, validate: false
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

  private

  def upcase_gtag
    self.tag_uid.upcase!
    self.tag_serial_number.upcase!
  end
end
