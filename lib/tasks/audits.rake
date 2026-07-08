namespace :audits do
  desc "Purge audits older than 30 days"
  task purge: :environment do
    count = Audited::Audit.where("created_at < ?", 30.days.ago).delete_all
    puts "Purged #{count} audits older than 30 days."
  end
end
