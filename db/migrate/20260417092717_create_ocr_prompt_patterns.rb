class CreateOcrPromptPatterns < ActiveRecord::Migration[8.1]
  def change
    create_table :ocr_prompt_patterns do |t|
      t.string :name, null: false
      t.text :prompt, null: false
      t.integer :position, default: 0
      t.boolean :is_default, default: false

      t.timestamps
    end

    add_index :ocr_prompt_patterns, :position
    add_index :ocr_prompt_patterns, :is_default
  end
end
