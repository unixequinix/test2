class PokesQuery
  def initialize(event)
    @event = event
  end

  def event_day_money
    Poke.connection.select_all(event_day_money_query).to_json
  end

  private

  def event_day_money_query
    <<-SQL
      SELECT event_day,
        event_day_sort,
        sum(onsite) as onsite,
        sum(online) as online
      FROM(SELECT
             to_char(date_trunc('day', date - INTERVAL '8 hour'), 'Mon-DD') as event_day,
             date_trunc('day', date - INTERVAL '8 hour') as event_day_sort,
             sum(monetary_total_price) as onsite,
             0 as online
           FROM pokes WHERE pokes.event_id = #{@event.id}
                              AND pokes.status_code = 0
                              AND pokes.error_code IS NULL
                              AND (pokes.monetary_total_price IS NOT NULL)
           GROUP BY event_day, event_day_sort
           UNION ALL
           SELECT
             to_char(date_trunc('day', completed_at), 'Mon-DD') as event_day,
             date_trunc('day', completed_at) as event_day_sort,
             0 as onsite, sum(money_base) as online

           FROM orders
           WHERE orders.event_id = #{@event.id}
                 AND orders.status = 3
                 AND (orders.money_base IS NOT NULL)
           GROUP BY event_day, event_day_sort
           UNION ALL
           SELECT
             to_char(date_trunc('day', created_at), 'Mon-DD') as event_day,
             date_trunc('day', created_at) as event_day_sort,
             0 as onsite, -1 * sum(credit_base) * #{@event.credit.value} as online

           FROM refunds
           WHERE refunds.event_id = #{@event.id}
                 AND refunds.status = 2
           GROUP BY event_day, event_day_sort
         ) money
      GROUP BY event_day, event_day_sort
      ORDER BY  event_day_sort
    SQL
  end
end
