class Customer < ApplicationRecord
  include Anony::Anonymisable
  acts_as_paranoid
  acts_as_tenant :account
  has_prefix_id :cust

  belongs_to :user, optional: true
  has_many :orders, dependent: :destroy

  before_validation :link_user_by_email
  after_save :sync_email_to_user, if: :saved_change_to_email_address?
  after_save :ensure_account_user, if: -> { saved_change_to_user_id? && user_id.present? }

  anonymise do
    overwrite do
      ignore :account_id, :user_id
      hex :name
      email :email_address
      hex :phone
    end
  end

  validates :name, presence: true

  private

  def link_user_by_email
    if email_address.present? && user.nil?
      self.user = User.find_by(email_address: email_address)
    end
  end

  def sync_email_to_user
    user&.update(email_address: email_address) if user&.email_address != email_address
  end

  def ensure_account_user
    return unless user && account
    # We use unscoped here to find/create AccountUser across any existing tenant context
    AccountUser.unscoped.where(account_id: account_id, user_id: user_id).first_or_create!(user_role: :customer)
  end
end
