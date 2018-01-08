class Station < ApplicationRecord
  ASSOCIATIONS = { accreditation:  %i[customer_portal box_office],
                   cs_accreditation:  %i[staff_accreditation cs_accreditation],
                   pos: %i[bar vendor],
                   topup: %i[top_up_refund hospitality_top_up cs_topup_refund cs_gtag_balance_fix],
                   access: [:access_control] }.freeze

  GROUPS = { access: %i[ticket_validation check_in box_office staff_accreditation access_control],
             event_management: %i[incident_report exhibitor customer_service customer_portal operator_permissions
                                  hospitality_top_up cs_topup_refund cs_gtag_balance_fix cs_accreditation gtag_replacement yellow_card],
             glownet: %i[gtag_recycler envelope_linker],
             monetary: %i[bar vendor top_up_refund],
             touchpoint: [:touchpoint] }.freeze

  CATEGORIES = GROUPS.values.flatten.map(&:to_s)

  belongs_to :event

  has_many :transactions, dependent: :restrict_with_error
  has_many :station_catalog_items, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :topup_credits, dependent: :destroy
  has_many :access_control_gates, dependent: :destroy
  has_many :stats, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :event_id, case_sensitive: false }
  validates :station_event_id, uniqueness: { scope: :event_id }
  validates :category, inclusion: { in: CATEGORIES, message: "Has to be one of: #{CATEGORIES.to_sentence}" }

  after_create :add_predefined_values
  before_create :add_station_event_id

  def form
    return unless category
    ASSOCIATIONS.find { |_, value| value.include?(category.to_sym) }&.first
  end

  def group
    return unless category
    GROUPS.find { |_, value| value.include?(category.to_sym) }&.first.to_s
  end

  def unassigned_catalog_items
    event.catalog_items - station_catalog_items.map(&:catalog_item)
  end

  def all_station_items
    topup_credits + station_catalog_items + products + access_control_gates
  end

  private

  def add_station_event_id
    self.station_event_id = event.stations.order(:station_event_id).pluck(:station_event_id).last.to_i + 1
  end

  def add_predefined_values
    return unless ASSOCIATIONS[:topup].include?(category.to_sym)
    return unless topup_credits.empty?

    amounts = [1, 5, 10]
    amounts += category.starts_with?("cs_") ? [0.01, 0.10, 0.50] : [20, 25, 50]
    amounts.each { |a| topup_credits.create!(amount: a, credit: event.credit) }
  end
end
