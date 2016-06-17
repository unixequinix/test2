class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    categories = %w(Credit Money Credential Access Order)
    @missing = {device: {}, profiles: []}

    categories.each do |cat|
      trans = "#{cat}Transaction".constantize.where(event: current_event).group_by(&:device_uid)
      trans.each do |uid, transactions|
        indexes = transactions.map(&:device_db_index).map(&:to_i).sort
        all_indexes = (1..indexes.last.to_i).to_a
        subset = all_indexes - indexes
        next if subset.empty?
        @missing[:device][uid] = {} unless @missing[uid]
        @missing[:device][uid][cat.downcase] = subset
      end
    end

    @missing[:profiles] = current_event.profiles
                                       .includes(:credit_transactions,
                                                :customer,
                                                :active_tickets_assignment,
                                                :active_gtag_assignment,
                                                credential_assignments: :credentiable)
                                       .select(&:missing_transactions?)

  end
end
