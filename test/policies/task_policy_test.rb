require "test_helper"

class TaskPolicyTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:one)
    @user = users(:one)
    @task = tasks(:one)
  end

  def test_scope
    scope = Pundit.policy_scope!(@user, Task)
    assert_includes scope, @task
  end

  def test_show
    assert TaskPolicy.new(@user, @task).show?
  end

  def test_create
    assert TaskPolicy.new(@user, Task.new).create?
  end

  def test_update
    assert TaskPolicy.new(@user, @task).update?
  end

  def test_complete
    assert TaskPolicy.new(@user, @task).complete?
  end

  def test_destroy
    assert TaskPolicy.new(@user, @task).destroy?
  end
end
