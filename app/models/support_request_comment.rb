class SupportRequestComment < ApplicationRecord
  audited associated_with: :account
  acts_as_tenant :account

  belongs_to :support_request
  belongs_to :user

  validates :body, presence: true
end
