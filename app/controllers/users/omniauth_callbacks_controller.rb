class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # SAML/OIDC コールバックは外部 IdP からの POST リクエストのため CSRF 検証をスキップ
  skip_before_action :verify_authenticity_token

  # DB から IdP を読み込んで動的にコールバックメソッドを定義
  # 注意: IdP を追加・変更した後はアプリの再起動が必要
  begin
    if ActiveRecord::Base.connection.table_exists?("identity_providers")
      IdentityProvider.where(enabled: true).find_each do |idp|
        method_name = "#{idp.provider_type}_#{idp.slug}"
        define_method(method_name) do
          handle_omniauth(method_name)
        end
      end
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid
    # マイグレーション前、DB接続不可、テーブルが存在しない場合はスキップ
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

      # 認証方式を判別（saml_ または oidc_ プレフィックスから）
      auth_method = provider_name.start_with?("saml_") ? "saml" : "oidc"

      sign_in_and_redirect @user, event: :authentication
      # セッションに認証方式を記録
      warden.session(:user)["auth_method"] = auth_method
      set_flash_message(:notice, :success, kind: display_name) if is_navigational_format?
    else
      redirect_to root_path, alert: "認証に失敗しました。"
    end
  end
end
