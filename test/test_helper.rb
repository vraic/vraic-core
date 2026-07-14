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
    end

    # Add more helper methods to be used by all tests here...
    def grant_support_access(account, user = nil)
      user ||= users(:administrator)
      SupportRequest.create!(
        account: account,
        requester: user,
        status: :accepted,
        expires_at: 72.hours.from_now,
        message: "Test authorization"
      )
    end
  end
end
