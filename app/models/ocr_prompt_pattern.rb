class OcrPromptPattern < ApplicationRecord
  has_many :images, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :prompt, presence: true

  scope :ordered, -> { order(:position, :created_at) }

  # デフォルトパターンを取得、なければ最初のパターン
  def self.default_or_first
    find_by(is_default: true) || ordered.first
  end

  # デフォルトパターンを設定（他のパターンの is_default をリセット）
  def set_as_default!
    transaction do
      OcrPromptPattern.where.not(id: id).update_all(is_default: false)
      update!(is_default: true)
    end
  end
end
