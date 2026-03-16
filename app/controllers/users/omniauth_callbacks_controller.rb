class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[saml]

  def saml
    handle_omniauth("SAML")
  end

  def openid_connect
    handle_omniauth("OIDC")
  end

  def failure
    redirect_to root_path, alert: "認証に失敗しました: #{failure_message}"
  end

  private

  def handle_omniauth(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      redirect_to root_path, alert: "#{provider_name} 認証に失敗しました。"
    end
  end
end
