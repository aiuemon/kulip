require "test_helper"

class PurgeOldFilesJobTest < ActiveJob::TestCase
  setup do
    Rails.cache.clear
  end

  test "does nothing when auto_purge_enabled is false" do
    Setting.auto_purge_enabled = false
    Setting.auto_purge_days = 7

    old_image = images(:old_completed_image)
    assert_not old_image.purged?

    PurgeOldFilesJob.perform_now

    old_image.reload
    assert_not old_image.purged?
  end

  test "purges old completed images when auto_purge_enabled is true" do
    Setting.auto_purge_enabled = true
    Setting.auto_purge_days = 7

    old_image = images(:old_completed_image)
    assert_not old_image.purged?

    PurgeOldFilesJob.perform_now

    old_image.reload
    assert old_image.purged?
    assert_nil old_image.ocr_result
  end

  test "does not purge recent images" do
    Setting.auto_purge_enabled = true
    Setting.auto_purge_days = 7

    recent_image = images(:completed_image)
    assert_not recent_image.purged?

    PurgeOldFilesJob.perform_now

    recent_image.reload
    assert_not recent_image.purged?
  end

  test "does not purge already purged images" do
    Setting.auto_purge_enabled = true
    Setting.auto_purge_days = 7

    purged_image = images(:purged_image)
    original_purged_at = purged_image.purged_at

    PurgeOldFilesJob.perform_now

    purged_image.reload
    assert_equal original_purged_at, purged_image.purged_at
  end

  test "uses effective_auto_purge_days setting" do
    Setting.auto_purge_enabled = true
    Setting.auto_purge_days = 30

    old_image = images(:old_completed_image)
    assert_not old_image.purged?

    PurgeOldFilesJob.perform_now

    old_image.reload
    assert_not old_image.purged?
  end
end
