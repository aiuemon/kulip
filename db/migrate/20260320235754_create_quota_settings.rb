class CreateQuotaSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :quota_settings do |t|
      t.integer :max_storage_per_user_mb, default: 1024

      t.timestamps
    end
  end
end
