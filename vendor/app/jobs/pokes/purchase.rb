class Pokes::Purchase < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[box_office_purchase].freeze

  def perform(transaction)
    atts = extract_money_atts(transaction, action: "purchase")
    item_atts = extract_catalog_item_info(transaction.catalog_item, atts)

    create_poke(extract_atts(transaction, item_atts))
  end
end
