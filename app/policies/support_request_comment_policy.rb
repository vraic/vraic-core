class SupportRequestCommentPolicy < ApplicationPolicy
  def create?
    # User can comment if they can show the support request
    SupportRequestPolicy.new(user, record.support_request).show?
  end

  def update?
    # Only platform admins can edit comments
    user.admin?
  end
end
