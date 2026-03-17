class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :status, null: false, default: "pending"
      t.text :ocr_result

      t.timestamps
    end
    add_index :images, :status
  end
end
