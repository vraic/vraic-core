class Customer < ApplicationRecord
  include Anony::Anonymisable
  acts_as_paranoid
  acts_as_tenant :account
  has_prefix_id :cust

  anonymise do
    overwrite do
      ignore :account_id
      hex :name
      email :email_address
      hex :phone
    end
  end

  validates :name, presence: true
end
