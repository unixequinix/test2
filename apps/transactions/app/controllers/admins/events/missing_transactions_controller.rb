class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    categories = %w(Credit Money Credential Access Order)
    @missing = {}

    categories.each do |cat|
      trans = "#{cat}Transaction".constantize.where(event: current_event).group_by(&:device_uid)
      trans.each do |uid, transactions|
        indexes = transactions.map(&:device_db_index).sort
        all_indexes = (1..indexes.last.to_i).to_a
        subset = all_indexes - indexes
        next if subset.empty?
        @missing[uid] = {} unless @missing[uid]
        @missing[uid][cat.downcase] = subset
      end
    end

    @missing
  end
end
