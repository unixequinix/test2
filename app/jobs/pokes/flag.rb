class Pokes::Flag < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[user_flag].freeze

  def perform(t)
    flag = t.event.user_flags.find_by(name: t.user_flag)
    atts = extract_catalog_item_info(flag).merge(user_flag_value: t.user_flag_active)

    create_poke(extract_atts(t, atts))
  end
end
