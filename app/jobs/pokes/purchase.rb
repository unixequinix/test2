class Pokes::Purchase < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[box_office_purchase].freeze

  def perform(t)
    atts = extract_money_atts(t, action: "purchase")
    item_atts = extract_catalog_item_info(t.catalog_item, atts)

    create_poke(extract_atts(t, item_atts))
  end
end
