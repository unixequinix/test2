module ReportsHelper

  def view_builder(operation_name, column_names, column_pivot, total = 'nill')
    sql = send "query_#{operation_name}", @current_event.id
    data = JSON.parse(Stat.connection.select_all(sql).to_json)
    result1 = send("pivot_#{operation_name}", data).to_json

    columns = column_names + data.map { |hash| hash[column_pivot] }.uniq.sort + ["total"]
    result2 = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json

    (total != 'nill') ? result3 = data.map {|i| i[total].to_i}.reduce(:+) : result3 = 0

    [result1, result2, result3]
  end

  def data_connection(query)
    JSON.parse(Stat.connection.select_all("#{query}").to_json)
  end


  # Gate Close -> Money Income ---------------------------------------------------------------------------------------
  def query_action_station_money(event_id)
    <<-SQL
          SELECT
            action,
            station_name,
            to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
            sum(monetary_total_price) as money
          FROM stats
            WHERE NOT monetary_total_price ISNULL AND event_id = #{event_id}
          GROUP BY 1, 2, 3
      SQL
  end

  def pivot_action_station_money(foo)
    foo = foo.group_by { |h| [h["station_name"], h["action"]] }
    foo.map do |_keys, arr|
      result = { "action" => arr.first["action"].humanize, "station_name" => arr.first["station_name"], "total" => number_to_delimited(arr.map { |i| i["money"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["money"]).to_f) }
      result
    end
  end

  # Gate Close -> Money Reconciliation by Operator -------------------------------------------------------------------
  def query_operator_recon(event_id)
    <<-SQL
        SELECT
          station_name,
          to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
          operator_uid,
          operator_name,
          device_name,
          action,
          catalog_item_name,
          payment_method,
          sum(monetary_total_price) as money
        FROM stats
          WHERE
          NOT monetary_total_price ISNULL
          AND event_id = #{event_id}
          AND origin = 'onsite'
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
      SQL
  end

  def pivot_operator_recon(foo)
    foo = foo.group_by do |h|
      [h["station_name"],
       h["event_day"],
       h["operator_uid"],
       h["operator_name"],
       h["device_name"],
       h["action"],
       h["catalog_item_name"]]
    end
    foo.map do |_keys, arr|
      result = { "station_name" => arr.first["station_name"],
                 "event_day" => arr.first["event_day"],
                 "operator_uid" => arr.first["operator_uid"],
                 "operator_name" => arr.first["operator_name"],
                 "device_name" => arr.first["device_name"],
                 "action" => arr.first["action"].humanize,
                 "catalog_item_name" => arr.first["catalog_item_name"],
                 "total" => number_to_delimited(arr.map { |i| i["money"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["payment_method"]] = number_to_delimited (hash["money"]).to_f }
      result
    end
  end

  # Gate Close -> Activations by Station and Event Day ---------------------------------------------------------------

  def query_activations(event_id)
    <<-SQL
    SELECT
      station_name,
      to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
      count(stats.customer_id) as activations
    FROM stats
      JOIN (SELECT
      customer_id,
      min(gtag_counter) as gtag_counter
      FROM stats
      WHERE event_id = #{event_id}
      GROUP BY 1) min ON min.customer_id = stats.customer_id AND min.gtag_counter = stats.gtag_counter
    GROUP BY 1,2
      SQL
  end

  def pivot_activations(foo)
    foo = foo.group_by { |h| [h["station_name"]] }
    foo.map do |_keys, arr|
      result = { "station_name" => arr.first["station_name"], "total" => number_to_delimited(arr.map { |i| i["activations"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["activations"]).to_i) }
      result
    end
  end

  # Gate Close -> Device Used ----------------------------------------------------------------------------------------
  def query_devices(event_id)
    <<-SQL
      SELECT
      station_name,
      to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
      count(DISTINCT stats.device_id) as devices_count
      FROM stats
      WHERE event_id = #{event_id}
      GROUP BY 1,2
      SQL
  end

  def pivot_devices(foo)
    foo = foo.group_by { |h| [h["station_name"]] }
    foo.map do |_keys, arr|
      result = { "station_name" => arr.first["station_name"], "total" => number_to_delimited(arr.map { |i| i["devices_count"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["devices_count"]).to_i) }
      result
    end
  end

  # Cashless -> Leftover Balance (Refundable and Non-Refundable) -------------------------------------------------------

  def query_leftover_balance(event_id)
    <<-SQL
      SELECT
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        credit_name,
        sum(credit_amount) as amount
      FROM stats
      WHERE event_id = #{event_id} and action in ('record_credit','fee','sale')
      GROUP BY 1,2
    SQL
  end

  def pivot_leftover_balance(foo)
    foo = foo.group_by { |h| [h["event_day"]]}
    foo.map do |_keys, arr|
      result = { "event_day" => arr.first["event_day"].humanize}
      arr.each { |hash| result[hash["credit_name"]] = number_to_delimited((hash["amount"]).to_f) }
      result
    end
  end

  # Cashless -> Credit Flow --------------------------------------------------------------------------------------------

  def query_credit_flow(event_id)
    <<-SQL
      SELECT
        COALESCE(name, action) as transaction_type,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        credit_name,
        sum(credit_amount) as amount
      FROM stats
      WHERE event_id = #{event_id} and action in ('record_credit','fee','sale')
      GROUP BY 1,2,3
    SQL
  end

  def pivot_credit_flow(foo)
    foo = foo.group_by { |h| [h["transaction_type"], h["credit_name"]]}
    foo.map do |_keys, arr|
      result = { "transaction_type" => arr.first["transaction_type"].humanize,
                 "credit_name" => arr.first["credit_name"].humanize,
                 "total" => number_to_delimited(arr.map { |i| i["amount"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["amount"]).to_f) }
      result
    end
  end

  # Cashless -> Topup & Refund by Station ------------------------------------------------------------------------------

  def query_topup_refund(event_id)
    <<-SQL
      SELECT
        COALESCE(name, action) as 
        transaction_type,
        location,
        station_type,
        station_name,
        credit_name,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        sum(credit_amount) as amount
      FROM stats
      WHERE event_id = #{event_id} and action in ('record_credit','fee')
      GROUP BY 1,2,3,4,5,6;
    SQL
  end

  def pivot_topup_refund(foo)
    foo = foo.group_by { |h|
      [h["transaction_type"],
       h["location"],
       h["station_type"],
       h["station_name"],
       h["credit_name"]]
    }
    foo.map do |_keys, arr|
      result = { "transaction_type" => arr.first["transaction_type"].humanize,
                 #"location" => arr.first["location"].humanize,
                 "station_type" => arr.first["station_type"].humanize,
                 "station_name" => arr.first["station_name"].humanize,
                 "credit_name" => arr.first["credit_name"].humanize,
                 "total" => number_to_delimited(arr.map { |i| i["amount"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["amount"]).to_f) }
      result
    end
  end

  # Cashless -> Sale by Station / Device -------------------------------------------------------------------------------
  def query_sales_by_station_device(event_id)
    <<-SQL
      SELECT
        station_type,
        station_name,
        device_name,
        credit_name,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        -1*sum(credit_amount) as total_amount
      FROM stats
      WHERE event_id = #{event_id}
      and action in ('sale', 'sale_refund')
      GROUP BY 1,2,3,4,5
    SQL
  end

  def pivot_sales_by_station_device(foo)
    foo = foo.group_by { |h| [h["station_type"], h["station_name"], h["device_name"], h["credit_name"]] }
    foo.map do |_keys, arr|
      result = {"station_type" => arr.first["station_type"].humanize,
                 "station_name" => arr.first["station_name"],
                 "device_name" => arr.first["device_name"],
                 "credit_name" => arr.first["credit_name"],
                 "total" => number_to_delimited(arr.map { |i| i["total_amount"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["total_amount"]).to_i) }
      result
    end
  end

  # Product Sales -> Sales by station category ----------------------------------------------------------------------------------
  def query_sales_by_station(event_id)
    <<-SQL
    SELECT
      location,
      station_type,
      station_name,
      to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
      credit_name,
      -1*sum(credit_amount) as total_amount
    FROM stats
    WHERE event_id = #{event_id}
    and action in ('sale', 'sale_refund')
    GROUP BY 1,2,3,4,5
    SQL
  end

  def pivot_sales_by_station(foo)
    foo = foo.group_by { |h| [h["location"], h["station_type"], h["station_name"], h["credit_name"]] }
    foo.map do |_keys, arr|
      result = { "station_type" => arr.first["station_type"].humanize, "station_name" => arr.first["station_name"], "total" => number_to_delimited(arr.map { |i| i["total_amount"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["total_amount"]).to_f) }
      result
    end
  end

  # Product Sales -> TOP 10 products sale -------------------------------------------------------------------------------------

  def query_top_products_by_quantity(event_id)
    <<-SQL
      SELECT
      product_name,
      sum(sale_item_quantity) as quantity
      FROM stats
      WHERE event_id = #{event_id} and action in ('sale', 'sale_refund')
      GROUP BY 1
      ORDER BY quantity DESC
      LIMIT 10
    SQL
  end

  def query_top_products_by_amount(event_id)
    <<-SQL
      SELECT
      product_name,
       -1*sum(credit_amount) as amount
      FROM stats
      WHERE event_id = #{event_id} and action in ('sale', 'sale_refund') and credit_value = 1
      GROUP BY 1
      ORDER BY amount DESC
      LIMIT 10
    SQL
  end

  # Performance by Station -------------------------------------------------------------------------------------

  def query_performance_by_station(event_id)
    <<-SQL
      SELECT
      station_name,
      to_char(date_trunc('hour', date), 'DD-MM-YYYY HH') as date_h,
      -1*sum(credit_amount) as amount
      FROM stats
      WHERE event_id = #{event_id} and action in ('sale', 'sale_refund') and credit_value = 1
      GROUP BY 1,2, date
      ORDER BY date
    SQL
  end

  # Product Sales -> Product Sale by station ----------------------------------------------------------------------------------
  def query_products_sale_station(event_id)
    <<-SQL
    SELECT
      station_type,
      station_name,
      to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
      product_name,
      credit_name,
      sum(sale_item_quantity) as total_quantity,
      -1*sum(credit_amount) as total_amount
    FROM stats
    WHERE event_id = #{event_id}
    and action in ('sale', 'sale_refund')
    GROUP BY 1,2,3,4,5
    SQL
  end

  def pivot_products_sale_station(foo)
    foo = foo.group_by { |h| [h["station_type"], h["station_name"], h["product_name"], h["credit_name"]] }
    foo.map do |_keys, arr|
    result = { "station_type" => arr.first["station_type"].humanize, "station_name" => arr.first["station_name"], "product_name" => arr.first["product_name"] , "total_quantity" => number_to_delimited(arr.map { |i| i["total_quantity"].to_i }.reduce(:+)), "total_amount" => number_to_delimited(arr.map { |i| i["total_amount"].to_f }.reduce(:+)) }
    arr.each { |hash| result[hash["event_day"]] = {"q" => number_to_delimited((hash["total_quantity"]).to_i), "a" => number_to_delimited((hash["total_amount"]).to_f)} }
    result
    end
  end

  # Gates -> Tickets Checked In ----------------------------------------------------------------------------------------
  def query_tickets_checkedin(event_id)
    <<-SQL
      SELECT
        action as transaction_type,
        ticket_type_name,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        count(credential_code) as ticket_count
      FROM stats
      where event_id = #{event_id} and action in ('checkin','ticket_validation')
      GROUP BY 1,2,3
    SQL
  end

  def pivot_tickets_checkedin(foo)
    foo = foo.group_by { |h| [h["transaction_type"], h["ticket_type_name"]] }
    foo.map do |_keys, arr|
      result = { "transaction_type" => arr.first["transaction_type"].humanize,
                 "ticket_type_name" => arr.first["ticket_type_name"],
                 "total" => number_to_delimited(arr.map { |i| i["ticket_count"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["ticket_count"]).to_i) }
      result
    end
  end

  # Gates -> Checkin Rate % --------------------------------------------------------------------------------------------

  def get_rate_data(a,b)
    data =[]

    a.each do |k,v|
      aux = {} # this is a hash
      aux["ticket_type"] = k

      if b[k].nil?
        r_aux = 0
      else
        r_aux = b[k]
      end
      r = (r_aux*100)/v
      aux["rate"] = "#{r}"
      data << aux
    end

    data
  end

  # Gates -> Tickets Checked-in - by Station ---------------------------------------------------------------------------

  def query_checkedin_by_station(event_id)
    <<-SQL
      SELECT
        action as transaction_type,
        station_name,
        ticket_type_name,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        count(credential_code) as ticket_count
      FROM stats
      where event_id = #{event_id} and action in ('checkin','ticket_validation')
      GROUP BY 1,2,3,4
    SQL
  end

  def pivot_checkedin_by_station(foo)
    foo = foo.group_by { |h| [h["transaction_type"], h["station_name"], h["ticket_type_name"]] }
    foo.map do |_keys, arr|
      result = { "transaction_type" => arr.first["transaction_type"].humanize,
                 "station_name" => arr.first["station_name"],
                 "ticket_type_name" => arr.first["ticket_type_name"],
                 "total" => number_to_delimited(arr.map { |i| i["ticket_count"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = number_to_delimited((hash["ticket_count"]).to_i) }
      result
    end
  end

  # Gates -> Accreditation ---------------------------------------------------------------------------------------------

  def query_accreditation(event_id)
    <<-SQL
      SELECT
        station_type,
        station_name,
        catalog_item_name,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        sum(monetary_quantity) as "total_quantity",
        sum(monetary_total_price) as "total_amount"
      FROM stats
      where event_id = #{event_id}
        AND action in ('purchase')
        AND station_type = 'box_office'
      GROUP BY 1,2,3,4
    SQL
  end

  def pivot_accreditation(foo)
    foo = foo.group_by { |h| [h["station_type"], h["station_name"], h["catalog_item_name"]] }
    foo.map do |_keys, arr|
      result = { "station_type" => arr.first["station_type"].humanize,
                 "station_name" => arr.first["station_name"],
                 "catalog_item_name" => arr.first["catalog_item_name"] ,
                 "total_quantity" => number_to_delimited(arr.map { |i| i["total_quantity"].to_i }.reduce(:+)),
                 "total_amount" => number_to_delimited(arr.map { |i| i["total_amount"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = {"q" => number_to_delimited((hash["total_quantity"]).to_i), "a" => number_to_delimited((hash["total_amount"]).to_f)} }
      result
    end
  end

  # Gates -> Access Control by Station ---------------------------------------------------------------------------------

  def query_access_ctrl_station(event_id)
    <<-SQL
      SELECT
        station_type,
        station_name,
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,

        sum(CASE access_direction
        when -1 then -access_direction
        ELSE 0
        END) as access_counter_in,

        sum(CASE access_direction
        when 1 then -access_direction
        ELSE 0
        END) as access_counter_out

      FROM stats
      where event_id =#{event_id}
        AND action in ('checkpoint')
        AND station_type = 'access_control'
      GROUP BY 1,2,3
    SQL
  end

  def pivot_access_ctrl_station (foo)
    foo = foo.group_by { |h| [h["station_type"], h["station_name"]] }
    foo.map do |_keys, arr|
      result = { "station_type" => arr.first["station_type"].humanize,
                 "station_name" => arr.first["station_name"],
                 "access_counter_in" => number_to_delimited(arr.map { |i| i["access_counter_in"].to_i }.reduce(:+)),
                 "access_counter_out" => number_to_delimited(arr.map { |i| i["access_counter_out"].to_i }.reduce(:+))}

      arr.each { |hash| result[hash["event_day"]] = {"in" => number_to_delimited((hash["access_counter_in"]).to_i), "out" => number_to_delimited((hash["access_counter_out"]).to_i)}}
      result
    end
  end

  # Gates -> Access Control - 30min ------------------------------------------------------------------------------------

  def query_access_ctrl_min(event_id)
    <<-SQL
      SELECT
        to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
        to_char(date_trunc('hour', date), 'DD-MM-YYYY HH24:') || right('0' || floor(extract(MINUTE FROM date) / 30) * 30, 2)
        as time_fraction,
        replace(replace(lower(replace(station_name, ' ', '')),'[','-'),']','') as station_name,

        sum(CASE access_direction
        when -1 then -access_direction
        ELSE 0
        END) as access_counter_in,

        sum(CASE access_direction
        when 1 then -access_direction
        ELSE 0
        END) as access_counter_out

      FROM stats
      where event_id = #{event_id}
        AND action in ('checkpoint')
        AND station_type = 'access_control'
      GROUP BY 1,2,3
    SQL
  end

  def pivot_access_ctrl_min (foo)
    foo = foo.group_by { |h| [h["event_day"], h["time_fraction"]] }
    foo.map do |_keys, arr|
      result = { "event_day" => arr.first["event_day"],
                 "time_fraction" => arr.first["time_fraction"],
                 "access_counter_in" => number_to_delimited(arr.map { |i| i["access_counter_in"].to_i }.reduce(:+)),
                 "access_counter_out" => number_to_delimited(arr.map { |i| i["access_counter_out"].to_i }.reduce(:+))}

      arr.each { |hash| result[hash["station_name"]] = {"in" => number_to_delimited((hash["access_counter_in"]).to_i), "out" => number_to_delimited((hash["access_counter_out"]).to_i)}}
      result
    end
  end


  # Product Sales -> Overall Product Sale ----------------------------------------------------------------------------------

  def query_products_sale_overall(event_id)
    <<-SQL
    SELECT
      product_name,
      to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
      sum(sale_item_quantity) as quantity,
      -1*sum(credit_amount) as amount
    FROM stats
    WHERE event_id = #{event_id}
    and action in ('sale', 'sale_refund')
    GROUP BY 1,2
    SQL
  end

  def pivot_products_sale_overall(foo)
    foo = foo.group_by { |h| [h["product_name"]] }
    foo.map do |_keys, arr|
      result = { "product_name" => arr.first["product_name"] , "total_quantity" => number_to_delimited(arr.map { |i| i["quantity"].to_i }.reduce(:+)), "total_amount" => number_to_delimited(arr.map { |i| i["amount"].to_f }.reduce(:+)) }
      arr.each { |hash| result[hash["event_day"]] = {"q" => number_to_delimited((hash["quantity"]).to_i), "a" => number_to_delimited((hash["amount"]).to_f)} }
      result
    end
  end

  # Operators Report -> Operators Sale ----------------------------------------------------------------------------------

  def query_operators_sale(event_id)
    <<-SQL
    SELECT
      station_type,
      station_name,
      operator_uid,
      operator_name,
      device_name,
      to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
      credit_name,
      product_name,
      sum(sale_item_quantity) as quantity,
      -1*sum(credit_amount) as amount
    FROM stats
      WHERE event_id = #{event_id}and action in ('sale_refund','sale')
      GROUP BY 1,2,3,4,5,6,7,8
    SQL
  end

  def pivot_operators_sale(foo)
    foo = foo.group_by {  |h| [h["station_type"], h["station_name"], h["operator_uid"], h["operator_name"], h["device_name"], h["event_day"], h["product_name"]] }
    foo.map do |_keys, arr|
      result = { "station_type" => arr.first["station_type"].humanize,
                 "station_name" => arr.first["station_name"],
                 "operator_uid" => arr.first["operator_uid"],
                 "operator_name" => arr.first["operator_name"],
                 "device_name" => arr.first["device_name"],
                 "event_day" => arr.first["event_day"],
                 "product_name" => arr.first["product_name"],
                 "total_quantity" => number_to_delimited(arr.map { |i| i["quantity"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["credit_name"]] =  number_to_delimited((hash["amount"]).to_f) }
      result
    end
  end

  def query_operators_money(event_id)
    <<-SQL
    SELECT
    station_type,
    station_name,
    operator_uid,
    operator_name,
    device_name,
    to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY') as event_day,
    action,
    catalog_item_name,
    payment_method,
    sum(monetary_total_price) as money
    FROM stats
      WHERE event_id = #{event_id}
            AND origin = 'onsite'
            AND NOT monetary_total_price ISNULL 
      GROUP BY 1,2,3,4,5,6,7,8,9
    SQL
  end


  def pivot_operators_money(foo)
    foo = foo.group_by {  |h| [h["station_type"], h["station_name"], h["operator_uid"], h["operator_name"], h["device_name"], h["event_day"], h["action"], h["catalog_item_name"]] }
    foo.map do |_keys, arr|
      result = { "station_type" => arr.first["station_type"].humanize,
                 "station_name" => arr.first["station_name"],
                 "operator_uid" => arr.first["operator_uid"],
                 "operator_name" => arr.first["operator_name"],
                 "device_name" => arr.first["device_name"],
                 "event_day" => arr.first["event_day"],
                 "action" => arr.first["action"],
                 "catalog_item_name" => arr.first["catalog_item_name"],
                 "total_money" => number_to_delimited(arr.map { |i| i["money"].to_i }.reduce(:+)) }
      arr.each { |hash| result[hash["payment_method"]] = number_to_delimited((hash["money"]).to_f) }
      result
    end
  end
end
