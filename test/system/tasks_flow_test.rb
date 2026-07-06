require "application_system_test_case"

class TasksFlowTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @account = accounts(:one)
    login_as(@user)
  end

  test "creating a task and seeing it on the index" do
    visit tasks_url
    assert_selector "h1", text: "Tasks"
    click_on "New Task"

    fill_in "task_title", with: "Real-time task"
    fill_in "task_description", with: "This task should appear instantly"
    select @user.name, from: "Responsible"

    # Optional: Test attachments if environment supports it, but usually standard file fields are fine.

    click_button "Create Task"

    assert_text "Task was successfully created"
    assert_text "Real-time task"
    assert_text @user.name
  end

  private

  def login_as(user)
    visit new_session_url
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    assert_text "Dashboard"
  end
end
