class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  before_action :fetch_issues

  def missing
    @issues.select! { |issue| issue["missing"] }
  end

  def real
    @issues.select! { |issue| !issue["missing"] }
  end

  private

  def fetch_issues
    @issues = Gtag.credits_sum(current_event)
    @counters = Gtag.counters(current_event)
    @issues.each do |issue|
      counters = @counters[issue["customer_id"].to_i]&.first
      next unless counters
      issue["missing"] = counters["gtag_total"] != counters["gtag_last_total"]
    end
  end
end
