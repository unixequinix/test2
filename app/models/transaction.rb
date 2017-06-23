class Transaction < ApplicationRecord
  include Alertable

  belongs_to :event
  belongs_to :station, optional: true
  belongs_to :customer, optional: true
  belongs_to :gtag, optional: true

  scope(:credit, -> { where(type: "CreditTransaction") })
  scope(:credential, -> { where(type: "CredentialTransaction") })
  scope(:access, -> { where(type: "AccessTransaction") })
  scope(:money, -> { where(type: "MoneyTransaction") })
  scope(:ban, -> { where(type: "BanTransaction") })
  scope(:orders, -> { where(type: "OrderTransaction") })
  scope(:device, -> { where(type: "DeviceTransaction") })
  scope(:onsite, -> { where(transaction_origin: ORIGINS[:device]) })
  scope(:online, -> { where(transaction_origin: [ORIGINS[:portal], ORIGINS[:admin]]) })

  scope(:with_event, ->(event) { where(event: event) })
  scope(:with_customer_tag, ->(tag_uid) { where(customer_tag_uid: tag_uid) })
  scope(:status_ok, -> { where(status_code: 0) })
  scope(:origin, ->(origin) { where(transaction_origin: Transaction::ORIGINS[origin]) })

  ORIGINS = { portal: "customer_portal", device: "onsite", admin: "admin_panel" }.freeze
  TYPES = %w[access credential credit money order operator user_engagement user_flag].freeze

  alias_attribute :name, :description

  def self.write!(event, action, origin, customer, operator, atts) # rubocop:disable Metrics/ParameterLists
    Time.zone = event.timezone
    now = Time.zone.now.to_formatted_s(:transactions)
    attributes = { event: event,
                   action: action,
                   counter: customer&.transactions&.maximum(:counter).to_i + 1,
                   customer: customer,
                   status_code: 0,
                   status_message: "OK",
                   transaction_origin: Transaction::ORIGINS[origin],
                   station: event.portal_station,
                   device_created_at: now,
                   device_created_at_fixed: now,
                   operator_tag_uid: operator&.email }.merge(atts)
    create!(attributes)
  end

  def category
    type.gsub("Transaction", "").underscore
  end

  def self.class_for_type(type)
    "#{type}_transaction".classify.constantize
  end

  def description
    "#{category.humanize}: #{action.humanize}"
  end

  def status_ok?
    status_code.zero?
  end

  def status_not_ok?
    !status_code.zero?
  end

  def self.mandatory_fields
    %w[action customer_tag_uid operator_tag_uid station_id device_uid device_db_index device_created_at status_code status_message]
  end
end
