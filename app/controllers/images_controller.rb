class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[show destroy retry download]

  def show
  end

  def destroy
    image_group = @image.image_group
    @image.destroy

    if image_group
      redirect_to image_group_path(image_group), notice: "画像を削除しました。"
    else
      redirect_to image_groups_path, notice: "画像を削除しました。"
    end
  end

  def retry
    if @image.retry_ocr!
      redirect_to image_path(@image), notice: "OCR 処理を再実行しました。"
    else
      redirect_to image_path(@image), alert: "OCR 処理を再実行できません。"
    end
  end

  def download
    unless @image.completed? && @image.ocr_result.present?
      redirect_to image_path(@image), alert: "ダウンロードできる結果がありません。"
      return
    end

    format = params[:format] || "txt"
    content, filename, content_type = DownloadContentFormatter.new(@image, format).generate

    send_data content, filename: filename, type: content_type, disposition: "attachment"
  end

  private

  def set_image
    @image = current_user.images.find(params[:id])
  end
end
