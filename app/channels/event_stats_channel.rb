class EventStatsChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])
    initial_stats(@event)
    stream_for(@event, coder: ActiveSupport::JSON) { |data| transmit render_stats(data["data"]) }
    transmit render(@data)
  end

  private

  def render_stats(atts) # rubocop:disable all
    atts.symbolize_keys!
    if atts[:action].in?(%w(sale topup)) && atts[:status_code].zero?
      @data[:topups] += atts[:credits] if atts[:action].eql?("topup")
      @data[:sales] += atts[:credits] if atts[:action].eql?("sale")
      @data[:num_gtags] += 1 if atts[:gtag_counter].eql?(1)
      @data[:refunds] += 1 if atts[:action].eql?("refund")
      @data[:fees] += atts[:credits] if atts[:action].ends_with?("_fee")
      @data[:box_office] += atts[:credits] if atts[:action].eql?("record_credit")

      stations = @data[:stations].find { |hash| hash[:id].eql?(atts[:station_id]) }
      stations[:data] += 1 if stations

      ops = find_or_create(@data[:stations], atts[:operator_tag_uid])
      ops[:data].eql?({}) ? ops[:data] = atts[:credits] : ops[:data] += atts[:credits]

      hc = find_or_create(@data[:credits_chart], atts[:action])
      hc[:data][atts[:device_created_at].to_date] = hc[:data][atts[:device_created_at].to_date].to_i + atts[:credits]
    end

    @data["num_#{atts[:category]}_trans".to_sym] += 1 if atts[:category].in? %w(credit money credential)
    hc2 = find_or_create(@data[:transactions_chart], atts[:category])
    hc2[:data][atts[:device_created_at].to_date] = hc2[:data][atts[:device_created_at].to_date].to_i + 1

    render(@data)
  end

  def initial_stats(event) # rubocop:disable all
    @data = { token_symbol: event.token_symbol, currency_symbol: event.currency, credit_value: event.credit.value, event_id: event.id }

    sales = event.transactions.credit.where(action: "sale")
    @data[:sales] = sales.sum(:credits)
    @data[:topups] = event.transactions.credit.where(action: "topup").sum(:credits)
    @data[:num_credit_trans] = event.transactions.credit.count
    @data[:num_money_trans] = event.transactions.money.count
    @data[:num_access_trans] = event.transactions.access.count
    @data[:num_credential_trans] = event.transactions.credential.count
    @data[:refunds] = event.transactions.credit.where(action: "refund").count
    @data[:box_office] = event.transactions.credit.where(action: "record_credit").count
    @data[:fees] = event.transactions.credit.where("action LIKE '%_fee'").count
    @data[:num_gtags] = event.gtags.count
    @data[:stations] = event.stations.map { |s| { id: s.id, name: s.name, data: sales.where(station: s).sum(:credits) } }
    @data[:operators] = sales.select(:credits, :operator_tag_uid).group_by(&:operator_tag_uid).to_a.map { |tag, ts| { name: tag, data: ts.sum(&:credits) } } # rubocop:disable Metrics/LineLength

    @data[:transactions_chart] = %w(credit money credential).map do |type|
      { name: type, data: event.transactions.send(type).group_by_day(:device_created_at).count }
    end

    @data[:credits_chart] = %w(sale topup).map do |action|
      data = event.transactions.credit.where(action: action).group_by_day(:device_created_at).sum(:credits)
      data = data.collect { |k, v| [k, v.to_i.abs] }
      { name: action, data: Hash[data] }
    end
  end

  def render(data)
    ApplicationController.render(partial: 'admins/events/numbers', locals: { data: data })
  end

  def find_or_create(arr, name)
    result = arr.find { |hash| hash[:name].eql?(name) }
    result = { name: name, data: {} } unless result
    arr << result unless result
    result
  end
end
