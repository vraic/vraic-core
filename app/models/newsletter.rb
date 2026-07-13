class Newsletter < ApplicationRecord
  acts_as_tenant :account

  has_rich_text :content

  enum :target, { everyone: 0, customers: 1, suppliers: 2 }

  validates :subject, :content, presence: true
end
