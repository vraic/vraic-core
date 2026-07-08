Rails.application.configure do
  config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] || "LX6p6rMZi50EM0tlvmpeESAWfl6Ecft6"
  config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] || "KlFX9r3Z4TH81Og0QPbjWe5WorzXRmkl"
  config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] || "tMhsZsQbZqofADt87sGxNsSLG3bbBKAi"
  config.active_record.encryption.support_unencrypted_data = true
end
