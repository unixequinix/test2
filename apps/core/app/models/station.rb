# == Schema Information
#
# Table name: stations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  name       :string           not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  location   :string
#  position   :integer
#  group      :string
#  category   :string
#

class Station < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :event
  belongs_to :station_type

  has_many :station_parameters
  has_many :station_catalog_items, through: :station_parameters,
                                   source: :station_parametable,
                                   source_type: "StationCatalogItem"

  has_many :station_products, through: :station_parameters,
                              source: :station_parametable,
                              source_type: "StationProduct"

  has_many :topup_credits, through: :station_parameters,
                           source: :station_parametable,
                           source_type: "TopupCredit"

  has_many :access_control_gates, through: :station_parameters,
                                  source: :station_parametable,
                                  source_type: "AccessControlGate"

  after_create :add_predefined_values

  ASSOCIATIONS = {
    accreditation:  [:customer_portal, :box_office, :staff_accreditation, :cs_accreditation],
    pos: [:bar, :vendor],
    topup: [:top_up_refund, :hospitality_top_up, :cs_topup_refund, :cs_gtag_balance_fix],
    access: [:access_control]
  }.freeze

  GROUPS = {
    access: [:ticket_validation, :check_in, :box_office, :customer_portal,
             :staff_accreditation, :access_control],
    event_management: [:incident_report, :exhibitor, :customer_service, :operator_permissions,
                       :payout_top_up, :hospitality_top_up, :cs_topup_refund,
                       :cs_gtag_balance_fix, :cs_accreditation],
    glownet: [:gtag_recycler, :envelope_linker],
    monetary: [:bar, :vendor, :top_up_refund],
    touchpoint: [:touchpoint]
  }.freeze

  def form
    ASSOCIATIONS.select { |_, value| value.include?(category.to_sym) }.first&.first
  end

  def unassigned_catalog_items
    event.catalog_items - station_catalog_items.map(&:catalog_item)
  end

  def unassigned_products
    event.products - station_products.map(&:product)
  end

  private

  def add_predefined_values
    return unless ASSOCIATIONS[:topup].include?(category.to_sym)

    amounts = [1, 5, 10]
    amounts += category.starts_with?("cs_") ? [0.01, 0.10, 0.50] : [20, 25, 50]
    amounts.each { |a| topup_credits.create!(amount: a, credit: event.credits.standard) }
  end
end
