class Newsletter < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :nl

  has_rich_text :content

  enum :target, { everyone: 0, customers: 1, suppliers: 2 }

  validates :subject, :content, presence: true
  validate :cannot_edit_if_sent, on: :update

  def sent?
    sent_at.present?
  end

  private

  def cannot_edit_if_sent
    if sent_at_was.present?
      errors.add(:base, "Cannot edit a newsletter that has already been sent")
    end
  end
end
