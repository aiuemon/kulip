class AddPurgedAtToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :purged_at, :datetime
    add_index :images, :purged_at
  end
end
