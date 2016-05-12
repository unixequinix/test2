class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def index
    @issues = []

    Profile.all.each do |profile|
      credits = profile.customer_credits.order(created_in_origin_at: :desc)
      last = credits.first
      amount_sum = credits.map(&:amount).sum
      refundable_sum = credits.map(&:refundable_amount).sum

      next unless last
      next if last.final_balance == amount_sum && last.final_refundable_balance == refundable_sum
      @issues << { profile: profile,
                   amount: amount_sum,
                   refundable: refundable_sum,
                   order_amount: last&.final_balance,
                   order_refundable: last&.final_refundable_balance }
    end
  end
end
