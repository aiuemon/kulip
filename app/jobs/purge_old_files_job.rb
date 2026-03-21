class PurgeOldFilesJob < ApplicationJob
  queue_as :default

  def perform
    return unless Setting.auto_purge_enabled?

    purged_count = 0

    Image.purgeable.find_each do |image|
      image.purge_file!
      purged_count += 1
    rescue StandardError => e
      Rails.logger.error "Failed to purge image #{image.id}: #{e.message}"
    end

    Rails.logger.info "PurgeOldFilesJob: Purged #{purged_count} images"
  end
end
