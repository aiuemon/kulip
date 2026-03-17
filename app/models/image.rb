class Image < ApplicationRecord
  STATUSES = %w[pending processing completed failed].freeze

  belongs_to :user
  has_one_attached :file

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :file, presence: true

  after_create_commit :enqueue_ocr_processing

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  # OCR 処理を再実行
  def retry_ocr!
    return unless failed? || pending?

    update!(status: "pending", ocr_result: nil)
    enqueue_ocr_processing
  end

  private

  def enqueue_ocr_processing
    return unless OcrApiClient.configured?

    OcrProcessJob.perform_later(id)
  end
end
