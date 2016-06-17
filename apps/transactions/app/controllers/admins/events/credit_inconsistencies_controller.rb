class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @issues = []


    Profile.find_by_sql("SELECT * FROM profiles AS profiles")




    current_event.profiles.joins(:credit_transactions,
                                    :access_transactions,
                                    :credential_transactions,
                                    :money_transactions,
                                    :order_transactions,
                                    :customer_credits)
                           .select('profiles.id', 'credit_transactions.gtag_counter', 'order_transactions.gtag_counter', 'money_transactions.gtag_counter', 'credential_transactions.gtag_counter', 'access_transactions.gtag_counter')
                           .page(params[:page]).per(100)
                           .each do |profile|
      next if profile.missing_transactions?
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
        id: profile.id,
        profile: profile,
        amount_sum_credit: amount_sum_credit,
        refundable_sum_credit: refundable_sum_credit,
        final_balance: last_credit.final_balance,
        final_refundable_balance: last_credit.final_refundable_balance,
        inconsistent_balance: ib,
        inconsistent_refundable_balance: irb
      }
    end
    @issues = @issues.sort_by! { |i| i[:inconsistent_balance] }
    @issues = Kaminari.paginate_array(@issues, total_count: @issues.size).page(params[:page]).per(100)
  end
end
