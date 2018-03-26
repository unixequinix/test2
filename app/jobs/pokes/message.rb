class Pokes::Message < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[exhibitor_note].freeze

  def perform(transaction)
    create_poke(extract_atts(transaction, message: transaction.message, priority: transaction.priority.to_i))
  end
end
