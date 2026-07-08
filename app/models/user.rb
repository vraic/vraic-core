class User < ApplicationRecord
  include Anony::Anonymisable
  acts_as_paranoid

  has_prefix_id :user
  has_secure_password

  encrypts :name, :email_address, deterministic: true
  encrypts :otp_secret
  encrypts :email_otp_token

  has_many :sessions, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users
  has_many :customers, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :tasks, foreign_key: :responsible_user_id, dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assigned_by_id, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :notes, dependent: :destroy
  has_many :support_requests, foreign_key: "requester_id", dependent: :destroy

  anonymise do
    overwrite do
      ignore :admin
      email :email_address
      hex :name
      with_strategy("ANONYMISED", :password_digest)
      ignore :otp_secret, :email_otp_token, :email_otp_sent_at, :otp_required_for_login
    end
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }
  validates :name, presence: true

  before_destroy :check_admin_flag

  after_save :sync_email_to_customers, if: :saved_change_to_email_address?
  after_create :link_existing_customers

  def otp_enabled?
    otp_secret.present? && otp_required_for_login?
  end

  def generate_otp_secret!
    update!(otp_secret: ROTP::Base32.random_base32)
  end

  def otp_qr_code
    return if otp_secret.blank?
    issuer = "Vraic OS"
    label = "#{issuer}:#{email_address}"
    totp = ROTP::TOTP.new(otp_secret, issuer: issuer)
    url = totp.provisioning_uri(label)
    RQRCode::QRCode.new(url)
  end

  def validate_otp(code)
    return false if otp_secret.blank?
    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code, drift_behind: 30)
  end

  def generate_email_otp!
    token = SecureRandom.alphanumeric(8).upcase
    update!(email_otp_token: token, email_otp_sent_at: Time.current)
    UserMailer.two_factor_code(self, token).deliver_later
  end

  def validate_email_otp(code)
    return false if email_otp_token.blank? || email_otp_sent_at < 15.minutes.ago
    email_otp_token == code.to_s.strip.upcase
  end

  def clear_email_otp!
    update!(email_otp_token: nil, email_otp_sent_at: nil)
  end

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
