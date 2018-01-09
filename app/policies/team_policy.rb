class TeamPolicy < ApplicationPolicy
  def devices?
    check_user_team
  end

  def show?
    check_user_team
  end

  def new?
    user.team.nil?
  end

  def create?
    user.team.nil?
  end

  def update?
    check_user_team && user.team_leader? || user.admin?
  end

  def destroy?
    check_user_team && user.team_leader? || user.admin?
  end

  def add_users?
    check_user_team && user.team_leader? || user.admin?
  end

  def remove_users?
    check_user_team && user.team_leader? && record.users.count > 1 || user.admin?
  end

  def add_devices?
    check_user_team || user.admin?
  end

  def remove_devices?
    check_user_team || user.admin?
  end

  def import_devices?
    check_user_team || user.admin?
  end

  def set_team?
    user&.team.present?
  end

  def change_role?
    check_user_team && user.team_leader? || user.admin?
  end

  def check_user_team
    user.team.present? && user.team == record
  end
end
