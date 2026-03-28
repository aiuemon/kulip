class ImageGroup < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy


  scope :recent, -> { order(created_at: :desc) }

  def completed_images
    images.where(status: "completed")
  end

  def images_count
    images.count
  end

  def completed_count
    completed_images.count
  end

  def all_completed?
    total = status_counts.values.sum
    total > 0 && status_counts["completed"].to_i == total
  end

  def any_failed?
    status_counts["failed"].to_i > 0
  end

  def all_failed?
    total = status_counts.values.sum
    total > 0 && status_counts["failed"].to_i == total
  end

  def processing?
    status_counts["processing"].to_i > 0
  end

  def status_summary
    return "処理中" if processing?
    return "失敗" if all_failed?
    return "一部失敗" if any_failed?
    return "完了" if all_completed?
    "待機中"
  end

  private

  # ステータスごとのカウントをメモ化
  # images がロード済みの場合は Ruby で集計、未ロードの場合は DB クエリを使用
  def status_counts
    @status_counts ||= build_status_counts
  end

  def build_status_counts
    if images.loaded?
      images.group_by(&:status).transform_values(&:size)
    else
      images.group(:status).count
    end
  end
end
