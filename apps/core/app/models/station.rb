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
#  group      :string
#  category   :string
#

class Station < ActiveRecord::Base
  default_scope { order("position ASC") }

  belongs_to :event

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

  after_create :add_basic_credit

  ASSOCIATIONS = {
    accreditation:  [:customer_portal, :box_office, :staff_accreditation],
    pos: [:point_of_sales],
    topup: [:top_up_refund, :hospitality_top_up],
    access: [:access_control]
  }.freeze

  GROUPS = {
    access: [:check_in, :box_office, :customer_portal, :staff_accreditation, :access_control],
    event_management: [:incident_report, :exhibitor, :customer_service, :operator_permissions,
                       :payout_top_up, :hospitality_top_up],
    glownet: [:dummy_check_in, :gtag_recycler, :envelope_linker],
    monetary: [:point_of_sales, :top_up_refund],
    touchpoint: [:touchpoint]
  }.freeze

  def form
    ASSOCIATIONS.select { |_, value| value.include?(category.to_sym) }.first&.first
  end

  def unassigned_catalog_items
    CatalogItem.where("id NOT IN (
                       SELECT station_catalog_items.catalog_item_id FROM station_catalog_items
                       INNER JOIN station_parameters
                       ON station_catalog_items.id = station_parameters.station_parametable_id
                       AND station_parameters.station_parametable_type = 'StationCatalogItem'
                       WHERE station_id = #{id})")
  end

  def unassigned_products
    Product.where("id NOT IN (
                   SELECT station_products.product_id FROM station_products
                   INNER JOIN station_parameters
                   ON station_products.id = station_parameters.station_parametable_id
                   AND station_parameters.station_parametable_type = 'StationProduct'
                   WHERE station_id = #{id})")
  end

  private

  def add_basic_credit
    return unless category == "top_up_refund"
    topup_credits.create!(amount: 1, credit: event.credits.standard)
  end
end
