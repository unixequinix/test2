class Admins::Events::CreditInconsistenciesController < Admins::Events::BaseController
  def missing
    @gtags = inconsistencies(@current_event).select { |gtag| !gtag.real }
    calculate_totals
  end

  def real
    @gtags = inconsistencies(@current_event).select(&:real)
    calculate_totals
  end

  private

  def calculate_totals
    @topups = @gtags.select { |gtag| gtag.inconsistency > 0 }.map(&:inconsistency).sum
    @topup_refundables = @gtags.select { |gtag| gtag.refundable_inconsistency > 0 }.map(&:refundable_inconsistency).sum
    @sales = @gtags.select { |gtag| gtag.inconsistency < 0 }.map(&:inconsistency).sum
    @sale_refundables = @gtags.select { |gtag| gtag.refundable_inconsistency < 0 }.map(&:refundable_inconsistency).sum
  end


  #TODO: Once UserEngagementTransactions start changing and sending gtag counter, remove the condition
  def inconsistencies(event)
    sql = <<-SQL
      SELECT
        gtags.*,
        gtags.final_balance - gtags.credits AS inconsistency,
        gtags.final_refundable_balance - gtags.refundable_credits AS refundable_inconsistency,
        MAX(gtag_counter) = COUNT(*) AS real
      FROM gtags LEFT JOIN transactions ON transactions.gtag_id = gtags.id and transactions.type != 'UserEngagementTransaction'
      WHERE
        gtags.event_id = #{event.id} AND
        (gtags.final_balance != gtags.credits OR gtags.final_refundable_balance != gtags.refundable_credits) AND
        transactions.status_code = 0
      GROUP BY gtags.id
      ORDER BY gtags.final_balance - gtags.credits DESC
    SQL
    Gtag.find_by_sql(sql)
  end
end
