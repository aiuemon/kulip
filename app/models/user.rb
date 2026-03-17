class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :omniauthable

  has_many :images, dependent: :destroy

  def self.from_omniauth(auth)
    # メールアドレスで既存ユーザーを検索、なければ作成
    where(email: auth.info.email).first_or_create do |user|
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
