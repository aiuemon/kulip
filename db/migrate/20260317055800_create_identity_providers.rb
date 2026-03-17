class CreateIdentityProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :identity_providers do |t|
      t.string :provider_type, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :enabled, null: false, default: false
      t.boolean :show_on_login, null: false, default: true
      t.json :settings, null: false, default: {}

      t.timestamps
    end

    add_index :identity_providers, :slug, unique: true
    add_index :identity_providers, :provider_type
    add_index :identity_providers, :enabled
  end
end
