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

  test "invalidate_all_sessions! sets sessions_invalidated_at" do
    user = users(:user)
    assert_nil user.sessions_invalidated_at

    user.invalidate_all_sessions!
    assert_not_nil user.sessions_invalidated_at
  end

  test "session_valid? returns true when sessions_invalidated_at is nil" do
    user = users(:user)
    user.sessions_invalidated_at = nil
    assert user.session_valid?(Time.current.to_i)
  end

  test "session_valid? returns false when signed_in_at is nil and sessions_invalidated_at is set" do
    user = users(:user)
    user.sessions_invalidated_at = Time.current
    assert_not user.session_valid?(nil)
  end

  test "session_valid? returns true when signed_in after invalidation" do
    user = users(:user)
    user.sessions_invalidated_at = 1.hour.ago
    signed_in_at = Time.current.to_i
    assert user.session_valid?(signed_in_at)
  end

  test "session_valid? returns false when signed_in before invalidation" do
    user = users(:user)
    signed_in_at = 2.hours.ago.to_i
    user.sessions_invalidated_at = 1.hour.ago
    assert_not user.session_valid?(signed_in_at)
  end
end
