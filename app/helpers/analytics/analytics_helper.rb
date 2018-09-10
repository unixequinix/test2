# rubocop:disable Style/GlobalVars
module Analytics::AnalyticsHelper
  def cache_control(action, expire, params)
    send(action, action, expire, params)
  end

  def set_cache(data, action, expire)
    key = "reports_queries:event:#{@current_event.id}:#{action}"
    $reports.setex(key, expire, data)
  end

  protected

  def event_analytics(action, expire, _params)
    data = $reports&.get(get_key(action)) || @current_event.plot(topups: @current_event.count_topups(grouping: :hour), sales: @current_event.count_sales(grouping: :hour), refunds: @current_event.count_all_refunds(grouping: :hour))
    return data if $reports.blank?
    set_cache(data.to_json.to_s, action, expire) unless $reports.exists(get_key(action))
    keys_to_date($reports.get(get_key(action)))
  end

  def credit_income(action, expire, params)
    set_cache(@current_event.credit_income(params[:group], params[:credit]).to_json, action, expire) unless $reports.exists(get_key(action))
    keys_to_date($reports.get(get_key(action)))
  end

  def credit_sales(action, expire, params)
    set_cache(@current_event.credit_sales(params[:group], params[:credit]).to_json, action, expire) unless $reports.exists(get_key(action))
    keys_to_date($reports.get(get_key(action)))
  end

  def credit_refunds(action, expire, params)
    set_cache(@current_event.credit_refunds(params[:group], params[:credit]).to_json, action, expire) unless $reports.exists(get_key(action))
    keys_to_date($reports.get(get_key(action)))
  end

  def credit_income_total(action, expire, params)
    set_cache(@current_event.credit_income_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_topups_base_total(action, expire, params)
    set_cache(@current_event.credit_topups_base_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_income_fees_total(action, expire, params)
    set_cache(@current_event.credit_income_fees_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_credential_total(action, expire, params)
    set_cache(@current_event.credit_credential_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_online_orders_income_total(action, expire, params)
    set_cache(@current_event.credit_online_orders_income_total(params[:credit], params[:payment_gateways], params[:credits]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_online_orders_income_purchase_total(action, expire, params)
    set_cache(@current_event.credit_online_orders_income_total(params[:credit], params[:payment_gateways], params[:catalog_items]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_box_office_total(action, expire, params)
    set_cache(@current_event.credit_box_office_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_outstanding_total(action, expire, params)
    set_cache(@current_event.credit_outstanding_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_online_refunds_base_total(action, expire, params)
    set_cache(@current_event.credit_online_refunds_base_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_onsite_refunds_base_total(action, expire, params)
    set_cache(@current_event.credit_onsite_refunds_base_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_outcome_fees_total(action, expire, params)
    set_cache(@current_event.credit_outcome_fees_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_online_orders_outcome_total(action, expire, params)
    set_cache(@current_event.credit_online_orders_outcome_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_outcome_total(action, expire, params)
    set_cache(@current_event.credit_outcome_total(params[:credit]), action, expire) unless $reports.exists(get_key(action))
    $reports.get(get_key(action))
  end

  def credit_sales_total(action, expire, params)
    set_cache(@current_event.credit_sales_total(params[:credit], params[:stations]), action, expire) unless $reports.exists(get_key(action, params[:subkey]))
    $reports.get(get_key(action))
  end

  private

  def get_key(action, subkey = nil)
    if subkey.present?
      "reports_queries:event:#{@current_event.id}:#{action}:#{subkey}"
    else
      "reports_queries:event:#{@current_event.id}:#{action}"
    end
  end

  def keys_to_date(hash)
    data = JSON.parse(hash)

    if data.is_a?(Array)
      data.map do |d|
        d.transform_keys do |key|
          Date.parse(key)
        rescue StandardError
          key
        end
      end
      data.map do |d|
        d.transform_values do |value|
          Date.parse(value)
        rescue StandardError
          value
        end
      end
    else
      data.transform_keys { |key| Date.parse(key) }
    end
  end
end
# rubocop:enable Style/GlobalVars
