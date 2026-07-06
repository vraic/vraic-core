class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

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
