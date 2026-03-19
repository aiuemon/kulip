require "test_helper"

module Admin
  class ImagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
      @image = images(:completed_image)
    end

    test "requires authentication" do
      get admin_images_path
      assert_redirected_to new_user_session_path
    end

    test "requires admin role" do
      sign_in @user
      get admin_images_path
      assert_redirected_to root_path
      assert_equal "管理者権限が必要です。", flash[:alert]
    end

    test "index returns success for admin" do
      sign_in @admin
      get admin_images_path
      assert_response :success
    end

    test "index supports sorting by name" do
      sign_in @admin
      get admin_images_path(sort: "name", dir: "asc")
      assert_response :success
    end

    test "index supports sorting by status" do
      sign_in @admin
      get admin_images_path(sort: "status", dir: "desc")
      assert_response :success
    end

    test "destroy deletes image" do
      sign_in @admin

      assert_difference "Image.count", -1 do
        delete admin_image_path(@image)
      end

      assert_redirected_to admin_images_path
    end
  end
end
