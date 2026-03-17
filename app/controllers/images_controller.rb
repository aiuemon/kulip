class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[show destroy retry download]

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
    content, filename, content_type = generate_download_content(@image, format)

    send_data content, filename: filename, type: content_type, disposition: "attachment"
  end

  def download_all
    images = current_user.images.where(status: "completed").where.not(ocr_result: nil)

    if images.empty?
      redirect_to images_path, alert: "ダウンロードできる結果がありません。"
      return
    end

    format = params[:format] || "txt"
    zip_data = generate_zip(images, format)

    send_data zip_data, filename: "ocr_results_#{Time.current.strftime('%Y%m%d%H%M%S')}.zip",
                        type: "application/zip", disposition: "attachment"
  end

  private

  def set_image
    @image = current_user.images.find(params[:id])
  end

  def generate_download_content(image, format)
    base_name = File.basename(image.name, ".*")

    case format
    when "md", "markdown"
      content = "# #{image.name}\n\n#{image.ocr_result}"
      [ content, "#{base_name}.md", "text/markdown" ]
    when "txt", "text"
      [ image.ocr_result, "#{base_name}.txt", "text/plain" ]
    else
      [ image.ocr_result, "#{base_name}.txt", "text/plain" ]
    end
  end

  def generate_zip(images, format)
    require "zip"

    stringio = Zip::OutputStream.write_buffer do |zio|
      images.each do |image|
        content, filename, = generate_download_content(image, format)
        zio.put_next_entry(filename)
        zio.write(content)
      end
    end

    stringio.rewind
    stringio.read
  end
end
