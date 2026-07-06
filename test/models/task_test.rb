require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @task = tasks(:one)
  end

  test "valid task" do
    assert @task.valid?
  end

  test "invalid without title" do
    @task.title = nil
    assert_not @task.valid?
  end

  test "belongs to account" do
    assert_instance_of Account, @task.account
  end

  test "belongs to responsible user" do
    assert_instance_of User, @task.responsible_user
  end

  test "belongs to assigned by" do
    assert_instance_of User, @task.assigned_by
  end

  test "can have attachments" do
    @task.attachments.attach(io: File.open(Rails.root.join("test/fixtures/files/test.png")), filename: "test.png", content_type: "image/png")
    assert @task.attachments.attached?
  end

  test "completion logic" do
    assert_not @task.completed?

    @task.complete!
    assert @task.completed?
    assert_not_nil @task.completed_at

    @task.incomplete!
    assert_not @task.completed?
    assert_nil @task.completed_at
  end

  test "completed and incomplete scopes" do
    @task.complete!
    assert_includes Task.completed, @task
    assert_not_includes Task.incomplete, @task

    @task.incomplete!
    assert_not_includes Task.completed, @task
    assert_includes Task.incomplete, @task
  end
end
