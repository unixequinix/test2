class Pokes::Checkpoint < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[access_checkpoint].freeze

  def perform(transaction)
    create_poke(extract_atts(transaction, extract_catalog_item_info(transaction.access, action: "checkpoint", access_direction: -transaction.direction)))
  end
end
