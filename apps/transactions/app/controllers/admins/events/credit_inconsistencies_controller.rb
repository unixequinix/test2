class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  before_action :fetch_issues

  def missing
    @issues.select! {|issue| issue["missing"] }
  end

  def real
    @issues.select! {|issue| not issue["missing"] }
  end

  private
  def fetch_issues
    @issues = Profile.customer_credits_sum(current_event)
    @counters = Profile.counters(current_event)
    @issues.each do |issue|
      counters = @counters[issue["profile_id"].to_i].first
      issue["missing"] = counters["gtag_total"] != counters["gtag_last_total"]
    end
  end
end
