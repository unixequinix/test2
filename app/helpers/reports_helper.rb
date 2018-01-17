module ReportsHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |stat| PokeSerializer.new(stat).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |stat| PokeSerializer.new(stat).to_h.slice(*atts) }
  end

  def query_activations(event_id)
    <<-SQL
      SELECT
        stations.category as "Station Type",
        stations.name as "Station Name",
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as "Event Day",
        pokes.action as "Action",
        count(pokes.customer_gtag_id) as "Activations"

      FROM pokes
        JOIN (SELECT
                customer_gtag_id,
                min(gtag_counter) as gtag_counter
              FROM pokes
              WHERE event_id = #{event_id}
              GROUP BY 1) min ON min.customer_gtag_id = pokes.customer_gtag_id AND min.gtag_counter = pokes.gtag_counter
        LEFT JOIN stations stations ON pokes.station_id = stations.id
      GROUP BY 1,2,3,4
    SQL
  end
end
