class CustomerPolicy < ApplicationPolicy
  def reset_password?
    admin_promoter_and_support
  end

  def download_transactions?
    admin_and_promoter
  end

  def new_credential?
    admin_promoter_and_support
  end

  def create_credential?
    admin_promoter_and_support
  end

  def destroy_credential?
    admin_promoter_and_support
  end
end
