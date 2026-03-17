class ImageGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image_group, only: %i[show destroy download]

  def index
    @image_groups = current_user.image_groups.recent.includes(images: { file_attachment: :blob })
  end

  def show
    @images = @image_group.images.with_attached_file.order(:created_at)
  end

  def new
    @image_group = current_user.image_groups.build
  end

  def create
    uploaded_files = params[:images] || []

    if uploaded_files.empty?
      redirect_to new_image_group_path, alert: "ファイルを選択してください。"
      return
    end

    group_name = params[:name].presence || "アップロード #{Time.current.strftime('%Y-%m-%d %H:%M')}"
    @image_group = current_user.image_groups.build(name: group_name)

    if @image_group.save
      uploaded_files.each do |file|
        @image_group.images.create(
          user: current_user,
          name: file.original_filename,
          file: file
        )
      end

      redirect_to image_group_path(@image_group), notice: "#{uploaded_files.size}件の画像をアップロードしました。"
    else
      redirect_to new_image_group_path, alert: "グループの作成に失敗しました。"
    end
  end

  def destroy
    @image_group.destroy
    redirect_to image_groups_path, notice: "グループを削除しました。"
  end

  def download
    images = @image_group.images.where(status: "completed").where.not(ocr_result: nil)

    if images.empty?
      redirect_to image_group_path(@image_group), alert: "ダウンロードできる結果がありません。"
      return
    end

    format = params[:format] || "txt"
    zip_data = generate_zip(images, format)
    filename = "#{@image_group.name.gsub(/[^\w\-]/, '_')}_#{Time.current.strftime('%Y%m%d%H%M%S')}.zip"

    send_data zip_data, filename: filename, type: "application/zip", disposition: "attachment"
  end

  private

  def set_image_group
    @image_group = current_user.image_groups.find(params[:id])
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
