class AddSessionsInvalidatedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :sessions_invalidated_at, :datetime
  end
end
