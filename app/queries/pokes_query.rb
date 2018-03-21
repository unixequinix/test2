class PokesQuery
  def initialize(event)
    @event = event
  end

  def event_day_money
    Poke.connection.select_all(event_day_money_query).to_json
  end

  def credits_flow_day
    Poke.connection.select_all(credits_flow_query).to_json
  end

  private

  def event_day_money_query
    <<-SQL
      SELECT event_day,
        event_day_sort,
        sum(onsite) as onsite,
        sum(online) as online
      FROM(SELECT
             to_char(date_trunc('hour', date - INTERVAL '8 hour'), 'Mon-DD HH24h') as event_day,
             date_trunc('hour', date - INTERVAL '8 hour') as event_day_sort,
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
             0 as onsite, sum(money_base + money_fee) as online

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

  def credits_flow_query
    <<-SQL
    SELECT date_time,
          date_time_sort,
          sum(sale) as sale,
          sum(record_credit) as record_credit
    FROM (
      SELECT  to_char(date_trunc('hour', date), 'Mon-DD HH24h') as date_time,
              date_trunc('hour', date) as date_time_sort,
              sum(CASE WHEN action = 'sale' then credit_amount ELSE 0 END) as sale,
              sum(CASE WHEN action = 'record_credit' then credit_amount ELSE 0 END) as record_credit
      FROM pokes
      WHERE pokes.event_id = #{@event.id}
            AND pokes.status_code = 0
            AND pokes.error_code IS NULL
            AND pokes.credit_id in (#{@event.credit.id}, #{@event.virtual_credit.id})
            AND pokes.description != 'record_credit'
      GROUP BY date_time_sort, date_time
      UNION ALL
      SELECT  to_char(date_trunc('day', completed_at), 'Mon-DD HH24h') as date_time,
              date_trunc('day', completed_at) as date_time_sort,
              0 as sale,
              sum(money_fee) / #{@event.credit.value}  + sum(order_items.amount) as record_credit
      FROM orders
          JOIN order_items ON order_items.order_id = orders.id
          JOIN catalog_items ON catalog_items.id = order_items.catalog_item_id
          AND orders.event_id = #{@event.id}
          AND (catalog_items.type in ('Credit', 'VirtualCredit'))
          AND orders.status = #{Order.statuses['completed']}
      GROUP BY date_time_sort, date_time
      UNION ALL
      SELECT
        to_char(date_trunc('hour', completed_at), 'Mon-DD HH24h') as date_time,
        date_trunc('day', completed_at) as date_time_sort,
        0 as sale,
        sum(money_fee) / #{@event.credit.value}  + sum(o.amount * i.amount) as record_credit
      FROM orders
        JOIN order_items o ON orders.id = o.order_id
        JOIN catalog_items item ON o.catalog_item_id = item.id
        JOIN pack_catalog_items i ON item.id = i.pack_id
        JOIN catalog_items item2 ON i.catalog_item_id = item2.id
        AND item.type in ('Pack')
        AND item2.type in ('Credit', 'VirtualCredit')
        AND item.event_id = #{@event.id}
        AND orders.status = #{Order.statuses['completed']}
      GROUP BY date_time_sort, date_time
      UNION ALL
      SELECT
      to_char(date_trunc('hour', tickets.updated_at), 'Mon-DD HH24h') as date_time,
      date_trunc('day', tickets.updated_at) as date_time_sort,
       0 as sales,
       sum(i.amount) as record_credit
       FROM tickets
          JOIN ticket_types ON tickets.ticket_type_id = ticket_types.id
          JOIN catalog_items item ON ticket_types.catalog_item_id = item.id
          JOIN pack_catalog_items i ON item.id = i.pack_id
          JOIN catalog_items item2 ON i.catalog_item_id = item2.id
          AND tickets.customer_id IS NOT NULL
          AND item2.type in ('Credit', 'VirtualCredit')
          AND item.event_id = #{@event.id}
      GROUP BY date_time_sort, date_time
      UNION ALL
      SELECT
          to_char(date_trunc('day', created_at), 'Mon-DD HH24h') as date_time,
          date_trunc('day', created_at) as date_time_sort,
          0 as sale,
          -1* sum(credit_base) as  record_credit
      FROM refunds
      WHERE status = 2 AND event_id = #{@event.id}
      GROUP BY date_time_sort, date_time
    ) credits
    GROUP BY date_time_sort, date_time
    ORDER BY date_time_sort ASC
    SQL
  end
end
