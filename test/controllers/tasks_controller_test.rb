require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should filter index by status" do
    @task.complete!

    # Default index (pending) should not include completed task
    get tasks_url
    assert_response :success
    assert_select "tr##{ActionView::RecordIdentifier.dom_id(@task)}", 0

    # Completed index should include completed task
    get tasks_url(status: "completed")
    assert_response :success
    assert_select "tr##{ActionView::RecordIdentifier.dom_id(@task)}", 1
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: {
        task: {
          description: @task.description,
          due_date: @task.due_date,
          title: "New Task",
          responsible_user_id: @user.id
        }
      }
    end

    assert_redirected_to tasks_url
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: {
      task: {
        description: "Updated description",
        title: @task.title
      }
    }
    assert_redirected_to tasks_url
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end

    assert_redirected_to tasks_url
  end

  test "should complete task" do
    assert_nil @task.completed_at
    patch complete_task_url(@task)
    assert_redirected_to tasks_url
    assert @task.reload.completed?
    assert_not_nil @task.completed_at
  end

  test "should incomplete task" do
    @task.complete!
    assert @task.completed?
    patch incomplete_task_url(@task)
    assert_redirected_to tasks_url
    assert_not @task.reload.completed?
    assert_nil @task.completed_at
  end
end
