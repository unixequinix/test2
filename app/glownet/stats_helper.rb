module StatsHelper
  def extract_credit_atts(credit, extra_atts = {})
    return {}.merge(extra_atts) unless credit

    { credit_id: credit.id, credit_name: credit.name, credit_value: credit.value }.merge(extra_atts)
  end

  def extract_money_atts(t, extra_atts = {})
    { payment_method: t.payment_method,
      monetary_quantity: 1,
      monetary_unit_price: t.price,
      currency: t.event.currency,
      monetary_total_price: t.price }.merge(extra_atts)
  end

  def extract_credential_atts(credential, extra_atts = {})
    return {}.merge(extra_atts) unless credential
    { credential_code: credential.reference,
      credential_type: credential.credential_type,
      purchaser_name: credential.try(:purchaser_full_name),
      purchaser_email: credential.try(:purchaser_email) }.merge(extra_atts)
  end

  def extract_ticket_type_info(ticket_type, extra_atts = {})
    return {}.merge(extra_atts) unless ticket_type

    { ticket_type_id: ticket_type.id,
      ticket_type_name: ticket_type.name,
      company_id: ticket_type.company.id,
      company_name: ticket_type.company.name }.merge(extra_atts)
  end

  def extract_catalog_item_info(item, extra_atts = {})
    return {}.merge(extra_atts) unless item

    { catalog_item_id: item.id,
      catalog_item_name: item.name,
      catalog_item_type: item.class.to_s }.merge(extra_atts)
  end

  def extract_atts(transaction, extra_atts = {}) # rubocop:disable Metrics/MethodLength
    device = Device.find_by(mac: transaction.device_uid)
    event = transaction.event
    station = transaction.station
    customer = transaction.customer

    {
      operation_id: transaction.id,
      origin: transaction.transaction_origin,
      date: transaction.device_created_at,
      action: transaction.action,
      event_id: event.id,
      event_name: event.name,
      line_counter: 1,
      device_id: device&.id,
      device_mac: device&.mac,
      device_name: device&.asset_tracker,
      station_id: station&.id,
      station_type: station&.category,
      station_name: station&.name,
      operator_uid: transaction.operator_tag_uid,
      event_series_id: event.event_serie&.id,
      event_series_name: event.event_serie&.name,
      customer_id: customer&.id,
      customer_name: customer&.name,
      customer_email: customer&.name,
      customer_uid: transaction.customer_tag_uid,
      gtag_counter: transaction.gtag_counter
    }.merge(extra_atts)
  end

  def extract_atts_from_sale_item(item, counter)
    product = item.product
    total = item.unit_price * item.quantity
    {
      line_counter: counter,
      product_id: product&.id,
      product_name: product&.name || "Other Amount",
      is_alcohol: product&.is_alcohol,
      sale_item_quantity: item.quantity,
      sale_item_unit_price: item.unit_price,
      sale_item_total_price: total,
      credit_amount: -total
    }
  end

  def create_stat(atts)
    begin
      stat = Stat.find_or_initialize_by(atts.slice(:line_counter, :operation_id))
      return stat unless stat.new_record?

      stat.update!(atts)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    stat
  end
end
