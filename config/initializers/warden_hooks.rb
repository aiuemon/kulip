# frozen_string_literal: true

# セッション管理とタイムアウトチェック
# - セッション無効化: sessions_invalidated_at がログイン時刻より後の場合
# - アイドルタイムアウト: 最終リクエストからの経過時間が設定値を超えた場合
Warden::Manager.after_set_user do |user, warden, options|
  scope = options[:scope]
  session_data = warden.session(scope)

  signed_in_at = session_data["signed_in_at"]
  auth_method = session_data["auth_method"]
  last_request_at = session_data["last_request_at"]

  # セッション無効化チェック
  if user.respond_to?(:session_valid?) && !user.session_valid?(signed_in_at)
    warden.logout(scope)
    throw :warden, scope: scope, message: :session_invalidated
  end

  # アイドルタイムアウトチェック（last_request_at が設定されている場合のみ）
  if last_request_at.present?
    timeout = Setting.timeout_for_auth_method(auth_method)
    last_request_time = Time.zone.at(last_request_at)
    if Time.current - last_request_time > timeout
      warden.logout(scope)
      throw :warden, scope: scope, message: :timeout
    end
  end

  # 最終リクエスト時刻を更新
  warden.session(scope)["last_request_at"] = Time.current.to_i
end

# ログイン時にセッション情報を記録
Warden::Manager.after_authentication do |user, warden, options|
  scope = options[:scope]
  warden.session(scope)["signed_in_at"] = Time.current.to_i
  warden.session(scope)["last_request_at"] = Time.current.to_i
  # デフォルトはローカル認証（SAML/OIDC/パスキーは各コントローラーで上書き）
  warden.session(scope)["auth_method"] ||= "local"
end
