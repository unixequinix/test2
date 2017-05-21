class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    user.admin? || user.event_ids.include?(record.scope_for_create["event_id"])
  end

  def show?
    admin_promoter_and_support
    scope.where(id: record.id).exists?
  end

  def create?
    admin_and_promoter && event_open
  end

  def new?
    admin_and_promoter && event_open
  end

  def update?
    admin_and_promoter && event_open
  end

  def edit?
    admin_and_promoter && event_open
  end

  def destroy?
    admin_and_promoter && record.event.created?
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

  def event_open
    !record.event.closed?
  end

  def admin_and_promoter
    user.admin? || (user.registration_for(record.event).promoter? && user.registration_for(record.event).accepted?)
  end

  def admin_promoter_and_support
    user.admin? || (user.registration_for(record.event).support? && user.registration_for(record.event).accepted?)
  end
end
