require "test_helper"

class OcrProcessJobTest < ActiveJob::TestCase
  test "skips non-existent image" do
    assert_nothing_raised do
      OcrProcessJob.perform_now(999999)
    end
  end

  test "skips non-pending image" do
    image = images(:completed_image)
    original_status = image.status

    OcrProcessJob.perform_now(image.id)

    image.reload
    assert_equal original_status, image.status
  end

  test "skips image without file" do
    image = images(:pending_image)
    # Fixture image doesn't have attached file
    assert_not image.file.attached?

    OcrProcessJob.perform_now(image.id)

    image.reload
    assert_equal "pending", image.status
  end

  test "job is enqueued to default queue" do
    assert_equal "default", OcrProcessJob.new.queue_name
  end

  test "job class exists and inherits from ApplicationJob" do
    assert OcrProcessJob < ApplicationJob
  end
end
