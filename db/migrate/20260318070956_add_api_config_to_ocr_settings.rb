class AddApiConfigToOcrSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :ocr_settings, :endpoint, :string, default: ""
    add_column :ocr_settings, :api_key, :string, default: ""
    add_column :ocr_settings, :timeout, :integer, default: 300
  end
end
