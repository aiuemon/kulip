class CreateOcrSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :ocr_settings do |t|
      t.string :model, default: ""
      t.text :prompt, default: ""
      t.json :options, default: {}

      t.timestamps
    end
  end
end
