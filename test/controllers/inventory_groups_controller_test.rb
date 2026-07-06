require "test_helper"

class InventoryGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @inventory_group = inventory_groups(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get inventory_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_inventory_group_url
    assert_response :success
  end

  test "should create inventory_group" do
    assert_difference("InventoryGroup.count") do
      post inventory_groups_url, params: { inventory_group: { account_id: @inventory_group.account_id, name: @inventory_group.name } }
    end

    assert_redirected_to inventory_group_url(InventoryGroup.last)
  end

  test "should show inventory_group" do
    get inventory_group_url(@inventory_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_inventory_group_url(@inventory_group)
    assert_response :success
  end

  test "should update inventory_group" do
    patch inventory_group_url(@inventory_group), params: { inventory_group: { account_id: @inventory_group.account_id, name: @inventory_group.name } }
    assert_redirected_to inventory_group_url(@inventory_group)
  end

  test "should destroy inventory_group" do
    assert_difference("InventoryGroup.count", -1) do
      delete inventory_group_url(@inventory_group)
    end

    assert_redirected_to inventory_groups_url
  end
end
