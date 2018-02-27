class Pokes::Checkpoint < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[access_checkpoint].freeze

  def perform(t)
    create_poke(extract_atts(t, extract_catalog_item_info(t.access, action: "checkpoint", access_direction: -t.direction)))
  end
end
