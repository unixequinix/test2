class TicketPolicy < ApplicationPolicy
  def destroy_multiple?
    admin_and_promoter
  end

  def import?
    admin_and_promoter
  end

  def sample_csv?
    admin_and_promoter
  end

  def ban?
    admin_and_promoter
  end

  def unban?
    admin_and_promoter
  end
end