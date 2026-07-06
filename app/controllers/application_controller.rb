class ApplicationController < ActionController::Base
  include Authentication
  include Authorization

  set_current_tenant_through_filter
  before_action :set_tenant

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def find_current_auditor
    Current.user if Current.user&.admin?
  end

  private

    def set_tenant
      return unless authenticated?

      if Current.user.admin?
        set_current_tenant(nil)
      else
        set_current_tenant(Current.user.accounts.first)
      end
    end
end
