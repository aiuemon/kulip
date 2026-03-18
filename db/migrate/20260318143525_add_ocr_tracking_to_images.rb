class AddOcrTrackingToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :ocr_duration, :integer
    add_column :images, :ocr_completed_at, :datetime
  end
end
