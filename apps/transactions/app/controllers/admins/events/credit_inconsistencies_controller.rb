class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @issues = []

    current_event.profiles.includes(
      :customer_credits,
      :active_gtag_assignment,
      :gtag_credit_transactions,
      active_gtag_assignment: :credentiable
    ).each do |profile|
      credits = profile.customer_credits
      last_credit = credits.first
      amount_sum_credit = credits.map(&:amount).sum
      refundable_sum_credit = credits.map(&:refundable_amount).sum

      transactions = profile.gtag_credit_transactions
      last_transaction = transactions.first
      amount_sum_transaction = transactions.map(&:credits).sum
      refundable_sum_transaction = transactions.map(&:credits_refundable).sum

      next unless last_credit
      next if last_credit.final_balance == amount_sum_credit &&
              last_credit.final_refundable_balance == refundable_sum_credit &&
              last_credit.final_balance >= 0 &&
              last_credit.final_refundable_balance >= 0
      @issues << { profile: profile,
                   amount_sum_credit: amount_sum_credit,
                   refundable_sum_credit: refundable_sum_credit,
                   final_balance: last_credit.final_balance,
                   final_refundable_balance: last_credit.final_refundable_balance,
                   inconsistent_balance: last_credit.final_balance - amount_sum_credit,
                   inconsistent_refundable_balance:
                    last_credit.final_refundable_balance - refundable_sum_credit,

                   final_transaction_balance: last_transaction.final_balance.to_i,
                   final_transaction_refundable_balance:
                    last_transaction.final_refundable_balance.to_i,
                   inconsistent_transaction_balance:
                    last_transaction.final_balance.to_i - amount_sum_transaction,
                   inconsistent_transaction_refundable_balance:
                    last_transaction.final_refundable_balance.to_i - refundable_sum_transaction,
                   gtag: profile.active_gtag_assignment&.credentiable&.tag_uid }
    end
    @issues.sort_by! { |i| i[:inconsistent_balance] }
  end
end
