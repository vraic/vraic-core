class SupportRequest < ApplicationRecord
  audited associated_with: :account
  acts_as_tenant :account

  belongs_to :account
  belongs_to :requester, class_name: "User"

  enum :status, { pending: 0, accepted: 1, rejected: 2, closed: 3, extension_requested: 4 }, default: :pending

  validates :message, presence: true

  scope :active, -> { accepted.where("expires_at > ?", Time.current) }

  def active?
    accepted? && expires_at.present? && expires_at > Time.current
  end

  def grant_authorization!
    update!(status: :accepted, expires_at: 72.hours.from_now)
  end
end
