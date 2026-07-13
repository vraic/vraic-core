class Newsletter < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :nl

  has_rich_text :content
  has_many :messages, class_name: "Ahoy::Message", dependent: :destroy

  enum :target, { everyone: 0, customers: 1, suppliers: 2 }

  validates :subject, :content, presence: true
  validate :cannot_edit_if_sent, on: :update

  def sent?
    sent_at.present?
  end

  def total_sent
    messages.count
  end

  def total_opened
    messages.where.not(opened_at: nil).count
  end

  def total_clicked
    messages.where.not(clicked_at: nil).count
  end

  def open_rate
    return 0 if total_sent.zero?
    (total_opened.to_f / total_sent * 100).round(1)
  end

  def click_rate
    return 0 if total_sent.zero?
    (total_clicked.to_f / total_sent * 100).round(1)
  end

  private

  def cannot_edit_if_sent
    if sent_at_was.present?
      errors.add(:base, "Cannot edit a newsletter that has already been sent")
    end
  end
end
