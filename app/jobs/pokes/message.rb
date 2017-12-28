class Pokes::Message < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[exhibitor_note].freeze

  def perform(t)
    create_poke(extract_atts(t, message: t.message, priority: t.priority.to_i))
  end
end
