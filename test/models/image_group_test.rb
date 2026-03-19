require "test_helper"

class ImageGroupTest < ActiveSupport::TestCase
  test "belongs to user" do
    group = image_groups(:group_with_images)
    assert_respond_to group, :user
    assert_not_nil group.user
  end

  test "has many images" do
    group = image_groups(:group_with_images)
    assert_respond_to group, :images
  end

  test "images_count returns number of images" do
    group = image_groups(:group_with_images)
    assert_equal group.images.count, group.images_count
  end

  test "completed_images returns only completed images" do
    group = image_groups(:group_with_images)
    group.completed_images.each do |image|
      assert_equal "completed", image.status
    end
  end

  test "completed_count returns number of completed images" do
    group = image_groups(:group_with_images)
    assert_equal group.completed_images.count, group.completed_count
  end

  test "all_completed? returns false for empty group" do
    group = image_groups(:empty_group)
    assert_not group.all_completed?
  end

  test "any_failed? returns true when any image failed" do
    group = image_groups(:group_with_images)
    assert group.any_failed?
  end

  test "processing? returns true when any image is processing" do
    group = image_groups(:admin_group)
    assert group.processing?
  end

  test "status_summary returns processing when processing" do
    group = image_groups(:admin_group)
    assert_equal "処理中", group.status_summary
  end

  test "all_failed? returns true when all images failed" do
    group = image_groups(:group_with_images)
    group.images.update_all(status: "failed")
    assert group.all_failed?
  end

  test "status_summary returns failed when all images failed" do
    group = image_groups(:group_with_images)
    group.images.update_all(status: "failed")
    assert_equal "失敗", group.status_summary
  end

  test "recent scope orders by created_at desc" do
    groups = ImageGroup.recent
    assert groups.first.created_at >= groups.last.created_at if groups.count > 1
  end
end
