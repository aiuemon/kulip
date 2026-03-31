class CreateWebauthnCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :webauthn_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.string :nickname
      t.bigint :sign_count, null: false, default: 0
      t.string :authenticator_type
      t.datetime :last_used_at
      t.timestamps

      t.index :external_id, unique: true
    end
  end
end
