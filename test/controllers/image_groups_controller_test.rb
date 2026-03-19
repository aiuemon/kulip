require "test_helper"

class ImageGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    @image_group = image_groups(:group_with_images)
  end

  test "requires authentication for index" do
    get image_groups_path
    assert_redirected_to new_user_session_path
  end

  test "index returns success" do
    sign_in @user
    get image_groups_path
    assert_response :success
  end

  test "index supports sorting by created_at" do
    sign_in @user
    get image_groups_path(sort: "created_at", dir: "asc")
    assert_response :success
  end

  test "index supports sorting by id" do
    sign_in @user
    get image_groups_path(sort: "id", dir: "desc")
    assert_response :success
  end

  test "show returns success" do
    sign_in @user
    get image_group_path(@image_group)
    assert_response :success
  end

  test "show requires ownership" do
    other_group = image_groups(:admin_group)

    sign_in @user
    get image_group_path(other_group)
    assert_response :not_found
  end

  test "new returns success" do
    sign_in @user
    get new_image_group_path
    assert_response :success
  end

  test "create without files redirects with alert" do
    sign_in @user
    post image_groups_path
    assert_redirected_to new_image_group_path
    assert_equal "ファイルを選択してください。", flash[:alert]
  end

  test "create with files creates image group" do
    sign_in @user
    file = fixture_file_upload("test_image.png", "image/png")

    assert_difference "ImageGroup.count", 1 do
      assert_difference "Image.count", 1 do
        post image_groups_path, params: { images: [ file ], memo: "テストメモ" }
      end
    end

    assert_redirected_to image_group_path(ImageGroup.last)
    assert_equal "1件の画像をアップロードしました。", flash[:notice]
  end

  test "destroy deletes image group" do
    sign_in @user

    assert_difference "ImageGroup.count", -1 do
      delete image_group_path(@image_group)
    end

    assert_redirected_to image_groups_path
  end

  test "download without completed images redirects with alert" do
    empty_group = image_groups(:empty_group)
    sign_in @user
    get download_image_group_path(empty_group)
    assert_redirected_to image_group_path(empty_group)
    assert_equal "ダウンロードできる結果がありません。", flash[:alert]
  end

  test "download returns zip file" do
    sign_in @user
    get download_image_group_path(@image_group, format: "txt")
    assert_response :success
    assert_equal "application/zip", response.content_type
  end
end
