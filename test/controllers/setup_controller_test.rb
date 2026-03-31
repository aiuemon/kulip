require "test_helper"

class SetupControllerTest < ActionDispatch::IntegrationTest
  def clear_all_users
    Image.delete_all
    ImageGroup.delete_all
    WebauthnCredential.delete_all
    User.delete_all
  end

  test "new redirects to root if setup completed" do
    # Fixtures have users, so setup is completed
    get new_setup_path
    assert_redirected_to root_path
  end

  test "new renders form if no users exist" do
    clear_all_users
    get new_setup_path
    assert_response :success
  end

  test "create creates admin user" do
    clear_all_users

    assert_difference "User.count", 1 do
      post setup_path, params: {
        user: {
          email: "admin@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    user = User.last
    assert user.admin?
  end

  test "create fails with invalid data" do
    clear_all_users

    assert_no_difference "User.count" do
      post setup_path, params: {
        user: {
          email: "invalid",
          password: "short",
          password_confirmation: "mismatch"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
