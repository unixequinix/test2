class CustomerPolicy < ApplicationPolicy
  def topup?
    all_allowed && event_open
  end

  def assign_gtag?
    all_allowed && event_open
  end

  def refunds?
    all_allowed
  end

  def transactions?
    all_allowed
  end

  def reset_password?
    all_allowed && event_open
  end

  def download_transactions?
    admin_or_promoter
  end

  def new_credential?
    all_allowed && event_open
  end

  def create_credential?
    all_allowed && event_open
  end

  def destroy_credential?
    all_allowed && event_open
  end
end
