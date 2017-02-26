class Station < ActiveRecord::Base
  belongs_to :event

  has_many :transactions, dependent: :restrict_with_error
  has_many :station_catalog_items, dependent: :destroy
  has_many :station_products, dependent: :destroy
  has_many :topup_credits, dependent: :destroy
  has_many :access_control_gates, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :event_id, case_sensitive: false }
  validates :station_event_id, uniqueness: { scope: :event_id }

  after_create :add_predefined_values
  before_validation :add_station_event_id

  ASSOCIATIONS = { accreditation:  [:customer_portal, :box_office, :staff_accreditation, :cs_accreditation],
                   pos: [:bar, :vendor],
                   topup: [:top_up_refund, :hospitality_top_up, :cs_topup_refund, :cs_gtag_balance_fix],
                   access: [:access_control, :ticket_validation] }.freeze

  GROUPS = { access: [:ticket_validation, :check_in, :box_office, :customer_portal, :staff_accreditation, :access_control],
             event_management: [:incident_report, :exhibitor, :customer_service, :operator_permissions, :hospitality_top_up, :cs_topup_refund, :cs_gtag_balance_fix, :cs_accreditation], # rubocop:disable Metrics/LineLength
             glownet: [:gtag_recycler, :envelope_linker],
             monetary: [:bar, :vendor, :top_up_refund],
             touchpoint: [:touchpoint] }.freeze

  def form
    ASSOCIATIONS.select { |_, value| value.include?(category.to_sym) }.first&.first
  end

  def unassigned_catalog_items
    event.catalog_items - station_catalog_items.map(&:catalog_item)
  end

  def unassigned_products
    event.products - station_products.map(&:product)
  end

  def all_station_items
    topup_credits + station_catalog_items + station_products + access_control_gates
  end

  private

  def add_station_event_id
    self.station_event_id ||= event.stations.order(:station_event_id).pluck(:station_event_id).last.to_i + 1
  end

  def add_predefined_values
    return unless ASSOCIATIONS[:topup].include?(category.to_sym)
    return unless topup_credits.empty?

    amounts = [1, 5, 10]
    amounts += category.starts_with?("cs_") ? [0.01, 0.10, 0.50] : [20, 25, 50]
    amounts.each { |a| topup_credits.create!(amount: a, credit: event.credit) }
  end
end
