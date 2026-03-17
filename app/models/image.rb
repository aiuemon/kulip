class Image < ApplicationRecord
  STATUSES = %w[pending processing completed failed].freeze

  belongs_to :user
  has_one_attached :file

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :file, presence: true

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
end
