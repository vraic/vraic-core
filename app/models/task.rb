class Task < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :task

  belongs_to :account
  belongs_to :responsible_user, class_name: "User"
  belongs_to :assigned_by, class_name: "User"

  has_many_attached :attachments

  validates :title, presence: true

  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def completed?
    completed_at.present?
  end

  def complete!
    update!(completed_at: Time.current)
  end

  def incomplete!
    update!(completed_at: nil)
  end

  broadcasts_to ->(task) { [ task.account, "tasks" ] }, inserts_by: :prepend
end
