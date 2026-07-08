class Note < ApplicationRecord
  audited associated_with: :account
  acts_as_tenant :account

  belongs_to :user
  belongs_to :notable, polymorphic: true

  validates :content, presence: true
end
