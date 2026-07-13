class Customer < ApplicationRecord
  audited associated_with: :account
  include SearchCop
  include Anony::Anonymisable
  acts_as_paranoid
  acts_as_tenant :account
  has_prefix_id :cust
  encrypts :name, :email_address, deterministic: true

  search_scope :search do
    attributes :name, :email_address, :phone
    attributes customer_account: "customer_account.name"
  end

  belongs_to :user, optional: true
  belongs_to :customer_account, class_name: "Account", optional: true
  has_many :orders, dependent: :destroy
  has_many :inventory_group_customers, dependent: :destroy
  has_many :inventory_groups, through: :inventory_group_customers

  before_validation :link_by_email
  after_save :sync_email_to_user, if: :saved_change_to_email_address?
  after_save :ensure_account_user, if: -> { saved_change_to_user_id? && user_id.present? }

  anonymise do
    overwrite do
      ignore :account_id, :user_id, :customer_account_id, :subscribed_to_newsletter
      hex :name
      email :email_address
      hex :phone
    end
  end

  validates :name, presence: true

  private

  def link_by_email
    if email_address.present?
      # Link User
      self.user ||= User.find_by(email_address: email_address)

      # Link Account
      if customer_account.nil? && user.present?
        # Use unscoped to find account users across all tenants
        target_account_users = AccountUser.unscoped.where(user_id: user.id)
        # Try to find account where they are owner
        account = Account.where(owner_id: user.id).first
        # Fallback to any account they belong to
        account ||= Account.where(id: target_account_users.select(:account_id)).first
        self.customer_account = account
      end
    end
  end

  def sync_email_to_user
    user&.update(email_address: email_address) if user&.email_address != email_address
  end

  def ensure_account_user
    return unless user_id && account_id
    # We use unscoped here to find/create AccountUser across any existing tenant context
    AccountUser.unscoped.where(account_id: account_id, user_id: user_id).first_or_create!(user_role: :customer)
  end
end
