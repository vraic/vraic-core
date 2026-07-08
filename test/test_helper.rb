ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    include ActionMailer::TestHelper
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      # Encrypt unencrypted data in fixtures for tests to work with ActiveRecord::Encryption
      # We need to do this because deterministic encryption queries won't find unencrypted data
      [ User, Customer, Supplier ].each do |klass|
        klass.unscoped.each do |record|
          record.email_address_will_change! if record.respond_to?(:email_address_will_change!)
          record.name_will_change! if record.respond_to?(:name_will_change!)
          record.save!
        end
      end
    end

    # Add more helper methods to be used by all tests here...
  end
end
