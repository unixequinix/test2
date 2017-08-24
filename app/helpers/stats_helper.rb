module StatsHelper
  def extract_atts_from_transaction(transaction)
    {
      transaction_id: transaction.id,
      source: transaction.transaction_origin,
      event_id: transaction.event.id,
      event_name: transaction.event.name,
      event_currency: transaction.event.currency,
      credit_name: transaction.event.credit.name,
      credit_value: transaction.event.credit.value,
      credit_symbol: transaction.event.credit.symbol,
      action: transaction.action,
      station_id: transaction.station_id,
      station_name: transaction.station.name,
      station_category: transaction.station.category,
      date: transaction.device_created_at,
      operator_tag_uid: transaction.operator_tag_uid,
      customer_tag_uid: transaction.customer_tag_uid,
      device_id: Device.find_by(mac: transaction.device_uid)&.id
    }
  end

  def extract_atts_from_sale_item(item, counter)
    {
      transaction_counter: counter,
      product_qty: item.quantity,
      product_id: item.product_id,
      product_name: item.product.name,
      total: -(item.unit_price * item.quantity)
    }
  end

  def create_stat(atts)
    begin
      stat = Stat.find_or_initialize_by(atts.slice(:transaction_counter, :transaction_id))
      return stat unless stat.new_record?

      stat.update!(atts)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    stat
  end
end
