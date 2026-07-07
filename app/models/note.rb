class Note < ApplicationRecord
  acts_as_tenant :account

  belongs_to :user
  belongs_to :notable, polymorphic: true

  validates :content, presence: true
end
