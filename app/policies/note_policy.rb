class NotePolicy < ApplicationPolicy
  def create?
    # Only staff can create notes
    staff?
  end

  private

  def staff?
    user.admin? || user.account_users.exists?(account: Current.account, user_role: [ :store_manager, :store_staff ])
  end
end
