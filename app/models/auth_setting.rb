class AuthSetting < ApplicationRecord
  # シングルトンとして使用
  def self.instance
    first_or_create!
  end

  def self.local_auth_enabled?
    instance.local_auth_enabled
  end

  def self.local_auth_show_on_login?
    instance.local_auth_show_on_login
  end

  def self.self_signup_enabled?
    instance.self_signup_enabled
  end
end
