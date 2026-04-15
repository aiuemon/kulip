class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable
  # Note: timeoutable は warden_hooks.rb で認証方式別に自前実装
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable

  has_many :images, dependent: :destroy
  has_many :image_groups, dependent: :destroy
  has_many :webauthn_credentials, dependent: :destroy

  before_create :generate_webauthn_id

  def self.from_omniauth(auth)
    # メールアドレスで既存ユーザーを検索、なければ作成
    where(email: auth.info.email).first_or_create do |user|
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def passkey_registered?
    webauthn_credentials.exists?
  end

  # 全セッションを無効化
  def invalidate_all_sessions!
    update!(sessions_invalidated_at: Time.current)
  end

  # セッションが有効かどうか（ログイン時刻が無効化時刻より後）
  def session_valid?(signed_in_at)
    return true if sessions_invalidated_at.nil?
    return false if signed_in_at.nil?

    # signed_in_at は Unix timestamp (Integer) で保存されている
    signed_in_time = Time.zone.at(signed_in_at)
    signed_in_time > sessions_invalidated_at
  end

  # ストレージ使用量（バイト）
  def storage_usage_bytes
    images.joins(file_attachment: :blob).sum("active_storage_blobs.byte_size")
  end

  # ストレージ使用量（MB）
  def storage_usage_mb
    storage_usage_bytes / 1.megabyte.to_f
  end

  # クォータ超過チェック
  def quota_exceeded?(additional_bytes = 0)
    (storage_usage_bytes + additional_bytes) > Setting.max_storage_bytes
  end

  # 残り容量（バイト）
  def available_storage_bytes
    [ Setting.max_storage_bytes - storage_usage_bytes, 0 ].max
  end

  # 残り容量（MB）
  def available_storage_mb
    available_storage_bytes / 1.megabyte.to_f
  end

  private

  def generate_webauthn_id
    self.webauthn_id ||= WebAuthn.generate_user_id
  end
end
