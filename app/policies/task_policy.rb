class TaskPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def create?
    staff?
  end

  def update?
    staff?
  end

  def complete?
    staff?
  end

  def destroy?
    staff?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        authorized_scope
      elsif staff?
        scope.all
      else
        scope.where(responsible_user: user)
      end
    end
  end
end
