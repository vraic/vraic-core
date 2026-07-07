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
      if staff?
        scope.all
      else
        scope.none
      end
    end
  end
end
