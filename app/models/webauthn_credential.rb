class WebauthnCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :sign_count, numericality: { greater_than_or_equal_to: 0 }

  AUTHENTICATOR_TYPES = %w[platform cross-platform].freeze

  validates :authenticator_type, inclusion: { in: AUTHENTICATOR_TYPES }, allow_nil: true

  def update_sign_count!(new_sign_count)
    update!(sign_count: new_sign_count, last_used_at: Time.current)
  end

  def display_name
    nickname.presence || "パスキー #{id}"
  end

  def authenticator_type_name
    case authenticator_type
    when "platform"
      "組み込み認証器"
    when "cross-platform"
      "セキュリティキー"
    else
      "不明"
    end
  end
end
