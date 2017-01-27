class TransactionPolicy < ApplicationPolicy
  def fix?
    admin_and_promoter
  end

  def search?
    admin_promoter_and_support
  end
end
