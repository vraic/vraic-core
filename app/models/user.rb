class User < ApplicationRecord
  include Anony::Anonymisable
  acts_as_paranoid

  has_prefix_id :user
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users
  has_many :tasks, foreign_key: :responsible_user_id, dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assigned_by_id, dependent: :destroy

  anonymise do
    overwrite do
      ignore :admin
      email :email_address
      hex :name
      with_strategy("ANONYMISED", :password_digest)
    end
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip.downcase }
  validates :name, presence: true

  before_destroy :check_admin_flag

  private

  def check_admin_flag
    throw :abort if admin?
    errors.add(:base, "Cannot delete admin users.")
  end
end
