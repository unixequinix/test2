class Admins::Events::InconsistenciesController < Admins::Events::BaseController
  def missing
    @gtags = inconsistencies(@current_event).select { |gtag| !gtag.real }
    calculate_totals
  end

  def resolvable
    @gtags = inconsistencies(@current_event, false).select { |gtag| !gtag.real } - inconsistencies(@current_event).select { |gtag| !gtag.real }
    calculate_totals
  end

  def real
    @gtags = inconsistencies(@current_event).select(&:real)
    calculate_totals
  end

  private

  def calculate_totals
    @topups = @gtags.select { |gtag| gtag.inconsistency.positive? }.map(&:inconsistency).sum
    @topup_refundables = @gtags.select { |gtag| gtag.refundable_inconsistency.positive? }.map(&:refundable_inconsistency).sum
    @sales = @gtags.select { |gtag| gtag.inconsistency.negative? }.map(&:inconsistency).sum
    @sale_refundables = @gtags.select { |gtag| gtag.refundable_inconsistency.negative? }.map(&:refundable_inconsistency).sum
  end

  # TODO: Once UserEngagementTransactions start changing and sending gtag counter, remove the condition
  def inconsistencies(event, only_good_transactions = true)
    good_transactions_sql = "AND transactions.status_code = 0"
    sql = <<-SQL
      SELECT
        gtags.*,
        gtags.final_balance - gtags.credits AS inconsistency,
        gtags.final_refundable_balance - gtags.refundable_credits AS refundable_inconsistency,
        MAX(gtag_counter) = COUNT(*) AS real
      FROM gtags LEFT JOIN transactions ON transactions.gtag_id = gtags.id and transactions.type != 'UserEngagementTransaction'
      WHERE
        gtags.event_id = #{event.id} AND
        (gtags.final_balance != gtags.credits OR gtags.final_refundable_balance != gtags.refundable_credits)
        #{good_transactions_sql if only_good_transactions}
      GROUP BY gtags.id
      ORDER BY gtags.final_balance - gtags.credits DESC
    SQL
    Gtag.find_by_sql(sql)
  end
end
