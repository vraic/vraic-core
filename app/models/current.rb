class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  delegate :user, to: :session, allow_nil: true
end
