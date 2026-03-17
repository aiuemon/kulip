class AddImageGroupToImages < ActiveRecord::Migration[8.1]
  def change
    add_reference :images, :image_group, null: true, foreign_key: true
  end
end
