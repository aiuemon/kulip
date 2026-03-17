class CreateAuthSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :auth_settings do |t|
      t.boolean :local_auth_enabled, null: false, default: true
      t.boolean :local_auth_show_on_login, null: false, default: true

      t.timestamps
    end
  end
end
