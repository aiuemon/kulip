class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_self_signup_enabled, only: %i[new create]

  private

  def check_self_signup_enabled
    unless Setting.self_signup_enabled?
      redirect_to new_user_session_path, alert: "新規登録は現在無効になっています。"
    end
  end
end
