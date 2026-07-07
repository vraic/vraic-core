class User < ApplicationRecord
  include Anony::Anonymisable
  acts_as_paranoid

  has_prefix_id :user
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users
  has_many :customers, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :tasks, foreign_key: :responsible_user_id, dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assigned_by_id, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :notes, dependent: :destroy

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

  after_save :sync_email_to_customers, if: :saved_change_to_email_address?
  after_create :link_existing_customers

  private

  def sync_email_to_customers
    customers.update_all(email_address: email_address)
    suppliers.update_all(email_address: email_address)
  end

  def link_existing_customers
    Customer.unscoped.where(email_address: email_address, user_id: nil).each do |customer|
      customer.update(user: self)
    end
    Supplier.unscoped.where(email_address: email_address, user_id: nil).each do |supplier|
      supplier.update(user: self)
    end
  end

  def check_admin_flag
    throw :abort if admin?
    errors.add(:base, "Cannot delete admin users.")
  end
end
