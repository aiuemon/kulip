require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test "valid statuses" do
    assert_equal %w[pending processing completed failed], Image::STATUSES
  end

  test "pending? returns true for pending status" do
    image = images(:pending_image)
    assert image.pending?
    assert_not image.processing?
    assert_not image.completed?
    assert_not image.failed?
  end

  test "processing? returns true for processing status" do
    image = images(:processing_image)
    assert image.processing?
    assert_not image.pending?
    assert_not image.completed?
    assert_not image.failed?
  end

  test "completed? returns true for completed status" do
    image = images(:completed_image)
    assert image.completed?
    assert_not image.pending?
    assert_not image.processing?
    assert_not image.failed?
  end

  test "failed? returns true for failed status" do
    image = images(:failed_image)
    assert image.failed?
    assert_not image.pending?
    assert_not image.processing?
    assert_not image.completed?
  end

  test "by_status scope filters by status" do
    completed_images = Image.by_status("completed")
    completed_images.each do |image|
      assert_equal "completed", image.status
    end
  end

  test "recent scope orders by created_at desc" do
    images = Image.recent
    assert images.first.created_at >= images.last.created_at if images.count > 1
  end

  test "belongs to user" do
    image = images(:completed_image)
    assert_respond_to image, :user
    assert_not_nil image.user
  end

  test "belongs to image_group optionally" do
    image = images(:completed_image)
    assert_respond_to image, :image_group
  end

  test "validates presence of name" do
    image = Image.new(status: "pending")
    assert_not image.valid?
    assert_includes image.errors[:name], "can't be blank"
  end

  test "validates status inclusion" do
    image = Image.new(name: "test.png", status: "invalid_status")
    assert_not image.valid?
    assert_includes image.errors[:status], "is not included in the list"
  end
end
