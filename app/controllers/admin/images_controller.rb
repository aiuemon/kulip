module Admin
  class ImagesController < BaseController
    SORTABLE_COLUMNS = %w[id name status ocr_duration ocr_completed_at created_at].freeze
    DEFAULT_SORT = "created_at".freeze
    DEFAULT_DIR = "desc".freeze

    before_action :set_image, only: %i[destroy]

    def index
      @sort = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : DEFAULT_SORT
      @dir = %w[asc desc].include?(params[:dir]) ? params[:dir] : DEFAULT_DIR

      scope = Image.includes(:user).order(@sort => @dir)

      @pagy, @images = pagy(scope)
    end

    def destroy
      @image.destroy
      redirect_to admin_images_path, notice: "画像を削除しました。"
    end

    private

    def set_image
      @image = Image.find(params[:id])
    end
  end
end
