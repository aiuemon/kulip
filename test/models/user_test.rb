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
end
