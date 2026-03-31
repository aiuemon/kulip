class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # SAML/OIDC コールバックは外部 IdP からの POST リクエストのため CSRF 検証をスキップ
  skip_before_action :verify_authenticity_token

  # 動的に IdP のコールバックを処理
  def method_missing(method_name, *args)
    if method_name.to_s.start_with?("saml_", "oidc_")
      handle_omniauth(method_name.to_s)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?("saml_", "oidc_") || super
  end

  def failure
    redirect_to root_path, alert: "認証に失敗しました: #{failure_message}"
  end

  private

  def handle_omniauth(provider_name)
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      # IdP 名を取得して表示
      idp_slug = provider_name.sub(/^(saml|oidc)_/, "")
      idp = IdentityProvider.find_by(slug: idp_slug)
      display_name = idp&.name || provider_name.upcase

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: display_name) if is_navigational_format?
    else
      redirect_to root_path, alert: "認証に失敗しました。"
    end
  end
end
