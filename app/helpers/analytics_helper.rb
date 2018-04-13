module AnalyticsHelper
  include ApplicationHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }
  end

  def grouper(array)
    array.inject { |memo, el| memo.merge(el) { |_k, old_v, new_v| old_v.to_f + new_v.to_f } } || []
  end

  def time_zoner(date, event)
    date.to_datetime.in_time_zone(event.timezone).strftime("%Y-%m-%d %Hh")
  end

  def event_day(date, event, delay = 8)
    (date.to_datetime.in_time_zone(event.timezone) - delay.hour).to_date
  end

  def pokes_sales(object, credit, rate = 1)
    sales = object.pokes.products_sale(credit).as_json.map { |p| p.merge('money' => -1 * p['credit_amount'] * rate) }
    sales.each do |p|
      p["date_time"] = time_zoner(p["date_time"], @current_event)
      p["event_day"] = event_day(p["date_time"], @current_event)
    end
  end

  def pokes_sale_quantity(object)
    products_stock = object.pokes.products_sale_stock.as_json
    products_stock.each do |p|
      p["date_time"] = time_zoner(p["date_time"], @current_event)
      p["event_day"] = event_day(p["date_time"], @current_event)
    end
  end

  def pokes_onsite_money(object)
    money = object.pokes.money_recon(%w[none other]).as_json
    money.each do |p|
      p["date_time"] = time_zoner(p["date_time"], @current_event)
      p["event_day"] = event_day(p["date_time"], @current_event)
    end
  end

  def pokes_onsite_credits(object)
    credits = object.pokes.credit_flow.as_json
    credits.each do |p|
      p["date_time"] = time_zoner(p["date_time"], @current_event)
      p["event_day"] = event_day(p["date_time"], @current_event)
    end
  end

  def pokes_checkin(object)
    ticket_codes = {}
    # TODO: update pokes and add ticket id
    @current_event.tickets.map { |t| ticket_codes.merge!([t.customer_id, t.ticket_type_id] => t.code) }
    checkin = object.pokes.checkin_ticket_type.as_json
    checkin.each do |p|
      p["date_time"] = time_zoner(p["date_time"], @current_event)
      p["event_day"] = event_day(p["date_time"], @current_event)
      p["code"] = ticket_codes[[p["customer_id"], p["ticket_type_id"]]]
    end
  end

  def pokes_access(object)
    access = object.pokes.access.as_json
    access.each do |p|
      p["date_time"] = time_zoner(p["date_time"], @current_event)
      p["event_day"] = event_day(p["date_time"], @current_event)
    end
  end
end
