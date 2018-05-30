module AnalyticsHelper
  include ApplicationHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }
  end

  def time_zoner(date)
    date.to_datetime.in_time_zone(@current_event.timezone).strftime("%Y-%m-%d %Hh")
  end

  def event_day(date, delay = 8)
    (date.to_datetime.in_time_zone(@current_event.timezone) - delay.hour).to_date
  end

  def pokes_money
    onsite_money = @current_event.pokes.money_recon(%w[none other]).as_json
    online_purchase = @current_event.orders.online_purchase.as_json
    online_purchase_fee = @current_event.orders.online_purchase_fee.as_json
    online_refunds = @current_event.refunds.online_refund.each { |o| o.money = o.money * @current_event.credit.value }.as_json
    products_sale = pokes_sales(@current_event.credit.id, @current_event.credit.value)
    money = onsite_money + online_purchase + online_purchase_fee + online_refunds + products_sale
    money.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def raw_data_money
    CSV.generate do |csv|
      csv << ['Action', 'Description', 'Source', 'Payment Method', 'Event Day', 'Date Time', 'Location', 'Station Type', 'Station Name', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Money', 'Number of Operations']
      data = %w[action description source payment_method event_day date_time location station_type station_name customer_uid customer_name operator_uid operator_name device_name money num_operations]
      pokes_money.map { |row| csv << data.map { |col| row[col] } }
    end
  end

  def pokes_credits
    credits_onsite = @current_event.pokes.credit_flow.as_json
    online_packs = Order.online_packs(@current_event).as_json
    ticket_packs = Ticket.online_packs(@current_event).as_json
    online_topup = @current_event.orders.online_topup.as_json
    credits_refunds = @current_event.refunds.online_refund_credits.each { |o| o.credit_name = @credit_name }.as_json
    credits_refunds_fee = @current_event.refunds.online_refund_fee.each { |o| o.credit_name = @credit_name }.as_json
    credits = online_packs + ticket_packs + online_topup + credits_onsite + credits_refunds + credits_refunds_fee
    credits.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def raw_data_credits
    CSV.generate do |csv|
      csv << ['Action', 'Description', 'Event Day', 'Date Time', 'Location', 'Station Type', 'Station Name', 'Device', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Credit Name', 'Credits', 'Number of Operations']
      data = %w[action description event_day date_time location station_type station_name device_name customer_uid customer_name operator_uid operator_name credit_name credit_amount num_operations]
      pokes_credits.map { |row| csv << data.map { |col| row[col] } }
    end
  end

  def pokes_sales_simple(credit, rate = 1)
    sales = @current_event.pokes.products_sale_simple(credit).as_json.map { |p| p.merge('money' => -1 * p['credit_amount'] * rate) }
    sales.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def pokes_sales(credit, rate = 1)
    sales = @current_event.pokes.products_sale(credit).as_json.map { |p| p.merge('money' => -1 * p['credit_amount'] * rate) }
    sales.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def raw_data_sales
    CSV.generate do |csv|
      csv << ['Description', 'Event Day', 'Date Time', 'Location', 'Station Type', 'Station Name', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Alcohol Product', 'Product Name', 'Credit Name', 'Credits', 'Number of Operations', 'Product Quantity']
      data = %w[description event_day date_time location station_type station_name customer_uid customer_name operator_uid operator_name device_name is_alcohol product_name credit_name credit_amount num_operations sale_item_quantity]
      pokes_sales(@current_event.credits.pluck(:id)).map { |row| csv << data.map { |col| row[col] } }
    end
  end

  def pokes_sale_quantity
    products_stock = @current_event.pokes.products_sale_stock.as_json
    products_stock.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def pokes_checkin
    ticket_codes = {}
    # TODO: update pokes and add ticket id
    @current_event.tickets.map { |t| ticket_codes.merge!([t.customer_id, t.ticket_type_id] => t.code) }
    checkin = @current_event.pokes.checkin_ticket_type.as_json
    checkin.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
      p['code'] = ticket_codes[[p['customer_id'], p['ticket_type_id']]]
    end
  end

  def raw_data_checkin
    CSV.generate do |csv|
      csv << ['Description', 'Event Day', 'Date Time', 'Location', 'Station Type', 'Station Name', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Ticket Code', 'Total Tickets']
      data = %w[description event_day date_time location station_type station_name customer_uid customer_name operator_uid operator_name device_name catalog_item_name ticket_type_name code total_tickets]
      pokes_checkin.map { |row| csv << data.map { |col| row[col] } }
    end
  end

  def pokes_access
    access = @current_event.pokes.access.as_json
    access.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def raw_data_access
    CSV.generate do |csv|
      csv << ["Station Name", "Event Day", "Date Time", "Direction", "Capacity", "Access", "Zone"]
      data = %w[station_name event_day date_time direction capacity access_direction zone]
      pokes_access.map { |row| csv << data.map { |col| row[col] } }
    end
  end

  def pokes_access_in_out(access)
    data = @current_event.pokes.access_in_out(access).as_json
    data.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
    end
  end

  def pokes_access_capacity(access)
    data = @current_event.pokes.access_capacity(access).as_json
    data.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      p['event_day'] = event_day(p['date_time'])
    end
  end

  def pokes_access_by_ticket_type(access)
    data = JSON.parse(PokesQuery.new(@current_event).access_by_ticket_type(access))
    tickets = JSON.parse(PokesQuery.new(@current_event).access_catalog_item_by_customer(access))
    customers = {}
    tickets.map { |t| customers.merge!([t["customer_id"], t["catalog_item_id"]].join => { customer_id: t["customer_id"], ticket_type: t["ticket_type"], access_name: t["access_name"], catalog_item: t["catalog_item"], checkin: t["checkin"] }) }
    data.each do |p|
      p['date_time'] = time_zoner(p['date_time'])
      key = [p['customer_id'], p['catalog_item_id']].join
      p["customer_id"] = customers[key][:customer_id]
      p["ticket_type_name"] = customers[key][:ticket_type]
      p["access_name"] = customers[key][:access_name]
      p["checkin"] = customers[key][:checkin]
      p["zone"] = access.name
      p["catalog_item_name"], = customers[key][:catalog_item]
    end
  end

  def raw_data_access_ticket_type
    CSV.generate do |csv|
      csv << ["Customer ID", "Date Time", "Ticket Type", "Catalog Item", "Access Name", "Check In", "Access", "Zone"]
      data = %w[customer_id date_time ticket_type_name catalog_item_name access_name checkin access_direction zone]
      accesses = @current_event.catalog_items.where(type: 'Access')
      access_by_ticket_type = []
      accesses.map { |access| access_by_ticket_type.append(pokes_access_by_ticket_type(access)) }
      access_by_ticket_type.flatten.map { |row| csv << data.map { |col| row[col] } }
    end
  end
end
