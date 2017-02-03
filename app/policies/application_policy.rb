class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    current_event_id = record.scope_for_create["event_id"]
    user.admin? ||
      (user.promoter? && user.owned_events.pluck(:id).include?(current_event_id)) ||
      (user.support? && user.event_id.eql?(current_event_id))
  end

  def show?
    admin_promoter_and_support
    scope.where(id: record.id).exists?
  end

  def create?
    admin_and_promoter
  end

  def new?
    admin_and_promoter
  end

  def update?
    admin_and_promoter
  end

  def edit?
    admin_and_promoter
  end

  def destroy?
    admin_and_promoter && %w(created launched).include?(record.event.state)
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def admin_and_promoter
    user.admin? || (user.promoter? && user.owned_events.include?(record.event))
  end

  def admin_promoter_and_support
    admin_and_promoter || (user.support? && user.event.eql?(record.event))
  end
end
