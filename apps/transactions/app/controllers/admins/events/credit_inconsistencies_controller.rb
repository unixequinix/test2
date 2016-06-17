class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @issues = []

    current_event.profiles.includes(:customer_credits,
                                    :active_gtag_assignment,
                                    active_gtag_assignment: :credentiable).each do |profile|
      next if profile.missing_credit_transactions?
      credits = profile.customer_credits
      last_credit = credits.first
      amount_sum_credit = credits.map(&:amount).sum.round(2)
      refundable_sum_credit = credits.map(&:refundable_amount).sum.round(2)

      next unless last_credit
      next if last_credit.final_balance == amount_sum_credit &&
              last_credit.final_refundable_balance == refundable_sum_credit &&
              last_credit.final_balance >= 0 &&
              last_credit.final_refundable_balance >= 0

      ib = (last_credit.final_balance - amount_sum_credit).round(2)
      irb = (last_credit.final_refundable_balance - refundable_sum_credit).round(2)

      @issues << {
        profile: profile,
        amount_sum_credit: amount_sum_credit,
        refundable_sum_credit: refundable_sum_credit,
        final_balance: last_credit.final_balance,
        final_refundable_balance: last_credit.final_refundable_balance,
        inconsistent_balance: ib,
        inconsistent_refundable_balance: irb,
        gtag: profile.active_gtag_assignment&.credentiable&.tag_uid
      }
    end
    @issues.sort_by! { |i| i[:inconsistent_balance] }
  end
end
