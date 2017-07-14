class EventStatsChannel < ApplicationCable::Channel
  def subscribed
    @event = Event.find(params[:id])
    stream_for(@event, coder: ActiveSupport::JSON) { transmit(render(@event)) }
    transmit render(@event)
  end

  private



  def render(event)
    stats = event.stats

    locals = {
      event:           event,
      payment_methods: stats.select(:payment_method).distinct.pluck(:payment_method).sort,
      online_topups:   stats.topups.online.group(:payment_method).sum(:total),
      onsite_topups:   stats.topups.onsite.group(:payment_method).sum(:total),
      online_refunds:  stats.refunds.online.group(:payment_method).sum(:total),
      onsite_refunds:  stats.refunds.onsite.group(:payment_method).sum(:total),
      sales:           stats.sales.onsite.group(:payment_method).sum(:total),
      sale_refunds:    stats.sale_refunds.group(:payment_method).sum(:total),
      initial_fees:    stats.initial_fees.group(:payment_method).sum(:total),
      topup_fees:      stats.topup_fees.group(:payment_method).sum(:total),
      deposit_fees:    stats.deposit_fees.group(:payment_method).sum(:total),
      return_fees:     stats.return_fees.group(:payment_method).sum(:total),
    }

    ApplicationController.render(partial: 'admins/events/stats/cashless_info', locals: locals)
  end
end
