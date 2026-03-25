class ImageGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image_group, only: %i[show destroy download]

  SORTABLE_COLUMNS = %w[id created_at].freeze
  DEFAULT_SORT = "created_at".freeze
  DEFAULT_DIR = "desc".freeze

  def index
    @sort = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : DEFAULT_SORT
    @dir = %w[asc desc].include?(params[:dir]) ? params[:dir] : DEFAULT_DIR

    scope = current_user.image_groups.includes(images: { file_attachment: :blob })
    scope = scope.order(@sort => @dir)

    @pagy, @image_groups = pagy(scope)
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

    # PDF ページ数チェック
    pdf_error = validate_pdf_pages(uploaded_files)
    if pdf_error
      redirect_to new_image_group_path, alert: pdf_error
      return
    end

    # クォータチェック
    total_size = uploaded_files.sum { |f| f.size }
    if current_user.quota_exceeded?(total_size)
      available_mb = current_user.available_storage_mb.round(1)
      redirect_to new_image_group_path, alert: "容量制限を超えています。残り容量: #{available_mb} MB"
      return
    end

    @image_group = current_user.image_groups.build(memo: params[:memo].presence)

    if @image_group.save
      uploaded_files.each do |file|
        @image_group.images.create(
          user: current_user,
          name: file.original_filename,
          file: file
        )
      end

      file_count = uploaded_files.size
      redirect_to image_group_path(@image_group), notice: "#{file_count}件のファイルをアップロードしました。"
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
    filename = "group_#{@image_group.id}_#{Time.current.strftime('%Y%m%d%H%M%S')}.zip"

    send_data zip_data, filename: filename, type: "application/zip", disposition: "attachment"
  end

  private

  def set_image_group
    @image_group = current_user.image_groups.find(params[:id])
  end

  def validate_pdf_pages(files)
    max_pages = Setting.effective_pdf_max_pages

    files.each do |file|
      next unless file.content_type == "application/pdf"

      begin
        pdf_service = PdfProcessingService.new(file.read, file.original_filename)
        file.rewind # read 後にポインタを戻す

        if pdf_service.exceeds_page_limit?
          return "PDF「#{file.original_filename}」のページ数（#{pdf_service.page_count}）が上限（#{max_pages}）を超えています。"
        end
      rescue PdfProcessingService::Error => e
        return "PDF「#{file.original_filename}」の読み取りに失敗しました: #{e.message}"
      end
    end

    nil
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
