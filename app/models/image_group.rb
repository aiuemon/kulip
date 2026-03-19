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
    images.any? && images.all?(&:completed?)
  end

  def any_failed?
    images.any?(&:failed?)
  end

  def all_failed?
    images.any? && images.all?(&:failed?)
  end

  def processing?
    images.any?(&:processing?)
  end

  def status_summary
    return "処理中" if processing?
    return "失敗" if all_failed?
    return "一部失敗" if any_failed?
    return "完了" if all_completed?
    "待機中"
  end
end
