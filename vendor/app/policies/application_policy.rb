class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @record = @record = record.is_a?(Array) ? record.last : record
  end

  def index?
    user.admin? || user.event_ids.include?(record.scope_for_create["event_id"])
  end

  def show?
    all_allowed && scope.where(id: record.id).exists?
  end

  def create?
    admin_or_promoter && event_open
  end

  def new?
    admin_or_promoter && event_open
  end

  def update?
    admin_or_promoter && event_open
  end

  def edit?
    admin_or_promoter && event_open
  end

  def destroy?
    admin_or_promoter && record.event.created?
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

  def event_created
    record.event.created?
  end

  def admin_or_promoter
    user.admin? || user.registration_for(record.try(:event) || record)&.promoter?
  end

  def admin_or_promoter_or(*roles)
    registration = user.registration_for(record.try(:event) || record)
    user.admin? || registration&.promoter? || roles.any? { |role| registration&.method("#{role}?".to_sym)&.call }
  end

  def admin_or_device_register
    user.admin? || user.registration_for(record)&.device_register?
  end

  def all_allowed
    registration = user.registration_for(record.try(:event) || record)
    user.admin? || (registration && (registration.support? || registration.promoter?))
  end

  def gates_manager?
    registration = user.registration_for(record)
    registration&.gates_manager?
  end
end
