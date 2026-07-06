require "test_helper"

class AdminDropdownReproTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:administrator)
    @admin.update!(admin: true)
    sign_in_as(@admin)
  end

  test "admin can see all accounts in the customer new form" do
    get new_customer_url
    assert_response :success

    puts "DEBUG: Account count: #{Account.count}"
    puts "DEBUG: Current.user.admin?: #{Current.user.admin?}"
    puts "DEBUG: ActsAsTenant.current_tenant: #{ActsAsTenant.current_tenant.inspect}"

    assert_select "select#customer_account_id" do |elements|
      puts "DEBUG: Found select#customer_account_id"
      assert_select "option" do |options|
        puts "DEBUG: Found #{options.size} options"
        options.each do |opt|
          puts "DEBUG: Option: #{opt.text}"
        end
      end
    end
  end
end
