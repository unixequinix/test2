module ReportsHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |stat| PokeSerializer.new(stat).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |stat| PokeSerializer.new(stat).to_h.slice(*atts) }
  end
end
