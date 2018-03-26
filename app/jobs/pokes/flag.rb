class Pokes::Flag < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[user_flag].freeze

  def perform(transaction)
    flag = transaction.event.user_flags.find_by(name: transaction.user_flag)
    atts = extract_catalog_item_info(flag).merge(user_flag_value: transaction.user_flag_active)

    create_poke(extract_atts(transaction, atts))
  end
end
