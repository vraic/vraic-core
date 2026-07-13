class Ahoy::Message < ActiveRecord::Base
  self.table_name = "ahoy_messages"

  belongs_to :user, polymorphic: true, optional: true
  belongs_to :newsletter, optional: true

  encrypts :to, deterministic: true
end
