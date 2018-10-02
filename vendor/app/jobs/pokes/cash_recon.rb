class Pokes::CashRecon < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[close_shift cash_withdrawal cash_addition float].freeze

  def perform(transaction)
    atts = { action: "cash_recon", description: transaction.action }
    create_poke(extract_atts(transaction, extract_money_atts(transaction, atts)))
  end
end
