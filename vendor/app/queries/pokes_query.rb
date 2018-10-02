class PokesQuery
  def initialize(event)
    @event = event
  end

  def access_by_ticket_type(access)
    Poke.connection.select_all(access_by_ticket_type_query(access)).to_json
  end

  def top_topup
    Poke.connection.select_all(top_topup_query).to_json
  end

  def customer_topup
    Poke.connection.select_all(customer_topup_query).to_json
  end

  def top_refund
    Poke.connection.select_all(top_refund_query).to_json
  end

  def top_product_quantity
    Poke.connection.select_all(top_product_quantity_query).to_json
  end

  def spending_customer
    Poke.connection.select_all(spending_customer_query).to_json
  end

  private

  def access_by_ticket_type_query(access)
    <<-SQL
      SELECT
        MIN(date) as date,
        date_trunc('hour', date) as date_time,
        pokes.catalog_item_id,
        stations.location as location,
        stations.category as station_type,
        stations.name as station_name,
        tickets.access_name,
        tickets.ticket_type as ticket_type_name,
        tickets.catalog_item as catalog_item_name,
        tickets.checkin,
        tickets.staff,
        count(pokes.customer_id) as access_direction
      FROM pokes
        JOIN stations ON pokes.station_id = stations.id
        JOIN (SELECT customer_id, min(gtag_counter) as min_gtag_counter
        FROM pokes
        WHERE action = 'checkpoint'
          AND event_id=#{@event.id}
          AND catalog_item_id in (#{access.id})
          GROUP BY customer_id
        ) first
        ON first.customer_id = pokes.customer_id AND first.min_gtag_counter = pokes.gtag_counter

      JOIN (
        SELECT
          customer_id,
          catalog_item_id,
          access_name,
          ticket_type,
          catalog_item_name as catalog_item,
          checkin,
          staff
        FROM (
        SELECT
          customer_id,
          COALESCE(item2.id, item.id) as catalog_item_id,
          COALESCE(item2.name, item.name) as access_name,
          item.name as catalog_item_name,
          t2.name as ticket_type,
          row_number() OVER(PARTITION BY customer_id, COALESCE(item2.id, item.id)) as row_number,
          'ticket' as checkin,
          CASE WHEN t2.operator = true THEN 'Staff' ELSE 'Customer' END as staff
        FROM tickets
          JOIN ticket_types t2 ON tickets.ticket_type_id = t2.id
          JOIN catalog_items item ON t2.catalog_item_id = item.id
          LEFT JOIN pack_catalog_items i ON item.id = i.pack_id
          LEFT JOIN catalog_items item2 ON i.catalog_item_id = item2.id
        WHERE COALESCE(item2.type, item.type) = 'Access'
          AND COALESCE(item2.id, item.id) = #{access.id}
        UNION ALL
        SELECT
          customer_id,
          COALESCE(item2.id, item.id) as catalog_item_id,
          COALESCE(item2.name, item.name) as access_name,
          item.name as catalog_item_name,
          item.name as ticket_type,
          row_number() OVER(PARTITION BY pokes.customer_id, pokes.catalog_item_id) as row_number,
          CASE WHEN pokes.payment_method ='none' THEN 'accreditation' ELSE 'box_office' END as checkin,
          CASE WHEN pokes.payment_method ='none' THEN 'accreditation' ELSE 'N/A' END as staff
        FROM pokes
          JOIN catalog_items item ON pokes.catalog_item_id = item.id
          LEFT JOIN pack_catalog_items i ON item.id = i.pack_id
          LEFT JOIN catalog_items item2 ON i.catalog_item_id = item2.id
        WHERE action = 'purchase'
           AND COALESCE(item2.type, item.type) = 'Access'
           AND COALESCE(item2.id, item.id) = #{access.id}
        UNION ALL
        SELECT
          customer_id,
          COALESCE(item2.id, item.id) as catalog_item_id,
          COALESCE(item2.name, item.name) as access_name,
          item.name as catalog_item_name,
          item.name as ticket_type,
          row_number() OVER(PARTITION BY orders.customer_id, o.catalog_item_id) as row_number,
          'order' as checkin,
          'N/A' as staff
        FROM orders
          JOIN order_items o ON orders.id = o.order_id
          JOIN catalog_items item ON o.catalog_item_id = item.id
          LEFT JOIN pack_catalog_items i ON item.id = i.pack_id
          LEFT JOIN catalog_items item2 ON i.catalog_item_id = item2.id
        WHERE COALESCE(item2.type, item.type) = 'Access' AND COALESCE(item2.id, item.id) = #{access.id}) cataglog_item
        WHERE row_number = 1
      ) tickets ON tickets.customer_id = pokes.customer_id AND tickets.catalog_item_id = pokes.catalog_item_id
      GROUP BY
        date_time,
        pokes.catalog_item_id,
        location,
        station_type,
        station_name,
        tickets.access_name,
        ticket_type_name,
        catalog_item_name,
        tickets.checkin,
        tickets.staff
    SQL
  end

  def top_topup_query
    <<-SQL
      SELECT to_char("Amount", '999') as "Amount", sum("Customers") as "Customers"
      FROM (
        SELECT
          orders.money_base as "Amount",
          count(customer_id) as "Customers"
        FROM orders
          JOIN order_items ON order_items.order_id = orders.id
          JOIN catalog_items ON catalog_items.id = order_items.catalog_item_id
          AND orders.event_id = #{@event.id}
          AND (catalog_items.type in ('Credit', 'VirtualCredit'))
          AND orders.status = #{Order.statuses['completed']}
        GROUP BY "Amount"
        UNION ALL
        SELECT
          monetary_total_price as "Amount",
          count(customer_id) as "Customers"
        FROM pokes
        WHERE
          pokes.event_id = #{@event.id}
          AND pokes.status_code = 0
          AND pokes.error_code IS NULL
        AND action = 'topup'
        GROUP BY "Amount"
      ) topup
      GROUP BY 1
      ORDER BY "Customers" DESC
      LIMIT 10
    SQL
  end

  def top_refund_query
    <<-SQL
    SELECT to_char("Amount", '999') as "Amount", sum("Customers") as "Customers"
      FROM
      (
        SELECT
          abs(monetary_total_price) as "Amount",
          count(customer_id) as "Customers"
        FROM pokes
        WHERE
          pokes.event_id = #{@event.id}
          AND pokes.status_code = 0
          AND pokes.error_code IS NULL
          AND action = 'refund'
        GROUP BY 1
        UNION ALL
        SELECT
          credit_base * #{@event.credit.value} as "Amount",
          count(customer_id) as "Customers"
        FROM refunds
        WHERE refunds.event_id = #{@event.id}
        GROUP BY 1
      ) refunds
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10
    SQL
  end

  def customer_topup_query
    <<-SQL
      SELECT to_char(topup_amount, '999') as lable,
       to_char((ROUND(sum(customer) / (SELECT count(id) FROM customers WHERE event_id = #{@event.id}), 4) * 100), '999.99') as metric
      FROM
      (
        SELECT
        orders.money_base as topup_amount,
        count(customer_id) as customer
        FROM orders
          JOIN order_items ON order_items.order_id = orders.id
          JOIN catalog_items ON catalog_items.id = order_items.catalog_item_id
          AND orders.event_id = #{@event.id}
          AND (catalog_items.type in ('Credit', 'VirtualCredit'))
          AND orders.status = #{Order.statuses['completed']}
        GROUP BY topup_amount
        UNION ALL
        SELECT
          monetary_total_price as topup_amount,
          count(customer_id) as customer
        FROM pokes
        WHERE
          pokes.event_id = #{@event.id} AND
          pokes.status_code = 0
          AND pokes.error_code IS NULL
          AND action = 'topup'
        GROUP BY topup_amount
      ) customers

      GROUP BY topup_amount
    SQL
  end

  def top_product_quantity_query
    <<-SQL
      SELECT
        product_name as "Product Name",
        sum(sale_item_quantity) as "Quantity",
        row_number() OVER (ORDER BY sum(sale_item_quantity) DESC) as sorter
      FROM (SELECT operation_id, sale_item_quantity, COALESCE(products.name, pokes.description) as product_name
        FROM pokes
          LEFT JOIN products ON pokes.product_id = products.id
        WHERE action = 'sale'
              AND event_id = #{@event.id}
        GROUP BY operation_id, sale_item_quantity, product_name) quant
      GROUP BY "Product Name"
      ORDER BY "Quantity" DESC
      LIMIT 10
    SQL
  end

  def spending_customer_query
    <<-SQL
      SELECT
        to_char(credit_amount, '999') as "Spent amount",
        count(customer_id) as "Customers"
      FROM(SELECT
           customer_id, round(abs(sum(credit_amount)), -1) as credit_amount
         FROM pokes
         WHERE action = 'sale' AND event_id = #{@event.id}
         GROUP BY customer_id) cust
      GROUP BY credit_amount
    SQL
  end
end
