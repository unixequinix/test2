class EventStatsChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])
    initial_stats(@event)
    stream_for(@event, coder: ActiveSupport::JSON) { |data| transmit(render_stats(data["data"])) if data["data"]["status_code"].zero? }
    transmit render(@data)
  end

  private

  def render_stats(atts) # rubocop:disable all
    atts.symbolize_keys!
    if atts[:type].eql?("CreditTransaction")
      @data[:topups] += atts[:credits].abs if atts[:action].eql?("topup")
      @data[:sales] += atts[:credits].abs if atts[:action].eql?("sale")
      @data[:refunds] += 1 if atts[:action].eql?("refund")
      @data[:fees] += atts[:credits].abs if atts[:action].ends_with?("_fee")
      @data[:actions][atts[:action]] = @data[:actions][atts[:action]].to_i + 1

      stations = @data[:stations].find { |hash| hash[:id].eql?(atts[:station_id]) }
      stations[:data] += 1 if stations

      hc = find_or_create(@data[:credits_chart], atts[:action])
      hc[:data][atts[:device_created_at].to_date] = hc[:data][atts[:device_created_at].to_date].to_i + atts[:credits].abs
    end

    @data[:not_on_date] += 1 unless (@event.start_date..@event.end_date).cover? atts[:device_created_at].to_date
    @data[:num_trans] += 1
    @data[:num_gtags] += 1 if atts[:gtag_counter].eql?(1)
    hc2 = find_or_create(@data[:transactions_chart], atts[:category])
    hc2[:data][atts[:device_created_at].to_date] = hc2[:data][atts[:device_created_at].to_date].to_i + 1

    render(@data)
  end

  def initial_stats(event) # rubocop:disable all
    @data = { credit_name: event.credit.name, currency_symbol: event.currency, credit_value: event.credit.value, event_id: event.id }

    transactions = event.transactions.where(device_created_at: event.start_date..event.end_date, status_code: 0)
    credit_transactions = transactions.credit

    sales = credit_transactions.where(action: "sale")
    @data[:not_on_date] = event.transactions.where.not(device_created_at: event.start_date..event.end_date).count
    @data[:sales] = sales.sum(:credits).abs
    @data[:topups] = credit_transactions.where(action: "topup").sum(:credits).abs
    @data[:num_trans] = transactions.count
    @data[:num_gtags] = event.gtags.count
    @data[:refunds] = credit_transactions.where(action: "refund").count
    @data[:fees] = credit_transactions.where("action LIKE '%_fee'").count
    @data[:stations] = event.stations.map { |s| { id: s.id, name: s.name, data: sales.where(station: s).sum(:credits).abs } }
    @data[:actions] = credit_transactions.group(:action).count

    @data[:transactions_chart] = %w[credit money credential].map do |type|
      { name: type, data: transactions.send(type).group_by_day(:device_created_at).count }
    end

    @data[:credits_chart] = %w[sale topup].map do |action|
      data = credit_transactions.where(action: action).group_by_day(:device_created_at).sum(:credits)
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
