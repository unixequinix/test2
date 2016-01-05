class Multitenancy::GeneralFetcher
  def initialize(event)
    @event = event
  end

  def tickets
    Ticket.where(event: @event).all
  end

  def gtags
    Gtag.where(event: @event).all
  end

  private

  def admin?
    @user.is_admin?
  end

  def manager?
    @user.is_manager?
  end
end
