require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
  end

  test "requires authentication" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "index renders dashboard for logged in user" do
    sign_in @user
    get root_path
    assert_response :success
  end
end
