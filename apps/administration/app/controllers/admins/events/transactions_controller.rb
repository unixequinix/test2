class Admins::Events::TransactionsController < Admins::Events::CheckinBaseController

  def index
    @transactions = Transaction.all.group_by(&:type)
  end
end