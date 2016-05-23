class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @issues = []

    current_event.profiles.includes(:customer_credits, :active_gtag_assignment).each do |profile|
      credits = profile.customer_credits.order(created_in_origin_at: :desc)
      last = credits.first
      amount_sum = credits.map(&:amount).sum
      refundable_sum = credits.map(&:refundable_amount).sum

      next unless last
      next if last.final_balance == amount_sum &&
              last.final_refundable_balance == refundable_sum &&
              last.final_balance >= 0 &&
              last.final_refundable_balance >= 0
      @issues << { profile: profile,
                   amount_sum: amount_sum,
                   refundable_sum: refundable_sum,
                   final_balance: last.final_balance,
                   final_refundable_balance: last.final_refundable_balance,
                   bad_balance: last.final_balance - amount_sum,
                   bad_refundable_balance: last.final_refundable_balance - refundable_sum,
                   reconciliation_balance: last.final_balance - amount_sum,
                   reconciliation_balance_refundable_balance: last.final_refundable_balance - refundable_sum,
                   gtag: profile.active_gtag_assignment&.credentiable&.tag_uid }
    end
  end
end
