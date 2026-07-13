namespace :ahoy do
  desc "Cleanup old analytics data (older than 30 days)"
  task cleanup: :environment do
    cutoff = 30.days.ago
    Ahoy::Visit.where("started_at < ?", cutoff).destroy_all
    Ahoy::Event.where("time < ?", cutoff).destroy_all
    Ahoy::Message.where("sent_at < ?", cutoff).destroy_all
    puts "Old analytics data cleaned up."
  end
end
