class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[show destroy]

  def index
    @images = current_user.images.recent.with_attached_file
  end

  def show
  end

  def new
    @image = current_user.images.build
  end

  def create
    uploaded_files = Array(params[:images])

    if uploaded_files.empty?
      redirect_to new_image_path, alert: "ファイルを選択してください。"
      return
    end

    created_count = 0
    uploaded_files.each do |file|
      image = current_user.images.build(
        name: file.original_filename,
        file: file
      )
      created_count += 1 if image.save
    end

    if created_count > 0
      redirect_to images_path, notice: "#{created_count}件の画像をアップロードしました。"
    else
      redirect_to new_image_path, alert: "アップロードに失敗しました。"
    end
  end

  def destroy
    @image.destroy
    redirect_to images_path, notice: "画像を削除しました。"
  end

  private

  def set_image
    @image = current_user.images.find(params[:id])
  end
end
