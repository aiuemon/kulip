require "test_helper"
require "ostruct"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = users(:user)
    assert user.valid?
  end

  test "admin user has admin flag" do
    admin = users(:admin)
    assert admin.admin?
  end

  test "normal user is not admin" do
    user = users(:user)
    assert_not user.admin?
  end

  test "user has many images" do
    user = users(:user)
    assert_respond_to user, :images
  end

  test "user has many image_groups" do
    user = users(:user)
    assert_respond_to user, :image_groups
  end

  test "from_omniauth creates user if not exists" do
    auth = OpenStruct.new(
      info: OpenStruct.new(email: "new_oauth_user@example.com")
    )

    assert_difference "User.count", 1 do
      User.from_omniauth(auth)
    end
  end

  test "from_omniauth returns existing user if exists" do
    existing_user = users(:user)
    auth = OpenStruct.new(
      info: OpenStruct.new(email: existing_user.email)
    )

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal existing_user.id, user.id
    end
  end

  test "storage_usage_bytes returns total size of uploaded images" do
    user = users(:user)
    assert_respond_to user, :storage_usage_bytes
    assert_kind_of Numeric, user.storage_usage_bytes
  end

  test "storage_usage_mb returns usage in megabytes" do
    user = users(:user)
    assert_respond_to user, :storage_usage_mb
    assert_kind_of Numeric, user.storage_usage_mb
  end

  test "quota_exceeded? returns false when under limit" do
    user = users(:user)
    Setting.max_storage_per_user_mb = 1024
    assert_not user.quota_exceeded?
  end

  test "available_storage_bytes returns remaining capacity" do
    user = users(:user)
    Setting.max_storage_per_user_mb = 1024
    assert_kind_of Numeric, user.available_storage_bytes
    assert user.available_storage_bytes >= 0
  end

  test "available_storage_mb returns remaining capacity in mb" do
    user = users(:user)
    Setting.max_storage_per_user_mb = 1024
    assert_kind_of Numeric, user.available_storage_mb
    assert user.available_storage_mb >= 0
  end
end
