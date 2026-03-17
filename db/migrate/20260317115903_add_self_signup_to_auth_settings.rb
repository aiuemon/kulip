class AddSelfSignupToAuthSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :auth_settings, :self_signup_enabled, :boolean, default: false, null: false
  end
end
