class RenameNameToMemoInImageGroups < ActiveRecord::Migration[8.1]
  def change
    rename_column :image_groups, :name, :memo
  end
end
