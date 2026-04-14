# frozen_string_literal: true

# セッション無効化チェック
# ユーザーの sessions_invalidated_at がセッション開始時刻より後の場合、
# セッションを無効化してログアウトさせる
Warden::Manager.after_set_user do |user, warden, options|
  scope = options[:scope]

  # セッションからログイン時刻を取得
  signed_in_at = warden.session(scope)["signed_in_at"]

  # セッションが無効化されている場合はログアウト
  if user.respond_to?(:session_valid?) && !user.session_valid?(signed_in_at)
    warden.logout(scope)
    throw :warden, scope: scope, message: :session_invalidated
  end
end

# ログイン時にセッション開始時刻を記録
Warden::Manager.after_authentication do |user, warden, options|
  scope = options[:scope]
  warden.session(scope)["signed_in_at"] = Time.current.to_i
end
