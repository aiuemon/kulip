class AddOcrPromptPatternToImages < ActiveRecord::Migration[8.1]
  def change
    add_reference :images, :ocr_prompt_pattern, null: true, foreign_key: true
    add_column :images, :ocr_prompt_text, :text
  end
end
