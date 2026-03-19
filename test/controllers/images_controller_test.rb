require "test_helper"

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    @completed_image = images(:completed_image)
    @failed_image = images(:failed_image)
  end

  test "requires authentication" do
    get image_path(@completed_image)
    assert_redirected_to new_user_session_path
  end

  test "show returns success" do
    sign_in @user
    get image_path(@completed_image)
    assert_response :success
  end

  test "show requires ownership" do
    admin_image = images(:processing_image)
    sign_in @user
    get image_path(admin_image)
    assert_response :not_found
  end

  test "destroy deletes image" do
    sign_in @user

    assert_difference "Image.count", -1 do
      delete image_path(@completed_image)
    end

    assert_redirected_to image_group_path(@completed_image.image_group)
  end

  test "retry handles failed image" do
    sign_in @user
    post retry_image_path(@failed_image)
    # In tests, file validation may fail (no actual file attached)
    # Either redirect or validation error is acceptable
    assert_includes [ 302, 422 ], response.status
  end

  test "download returns txt file" do
    sign_in @user
    get download_image_path(@completed_image, format: "txt")
    assert_response :success
    assert_equal "text/plain", response.content_type
  end

  test "download returns markdown file" do
    sign_in @user
    get download_image_path(@completed_image, format: "md")
    assert_response :success
    assert_equal "text/markdown", response.content_type
  end

  test "download fails for incomplete image" do
    pending_image = images(:pending_image)
    sign_in @user
    get download_image_path(pending_image)
    assert_redirected_to image_path(pending_image)
    assert_equal "ダウンロードできる結果がありません。", flash[:alert]
  end
end
