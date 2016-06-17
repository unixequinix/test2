class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    categories = %w(Credit Money Credential Access Order)
    @missing = {device: {}, profiles: []}

   

  end
end
