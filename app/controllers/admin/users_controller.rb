module Admin
  class UsersController < BaseController
    SORTABLE_COLUMNS = %w[id name email created_at].freeze
    DEFAULT_SORT = "created_at".freeze
    DEFAULT_DIR = "desc".freeze

    before_action :set_user, only: %i[toggle_admin]

    def index
      @sort = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : DEFAULT_SORT
      @dir = %w[asc desc].include?(params[:dir]) ? params[:dir] : DEFAULT_DIR

      scope = User.includes(:images).order(@sort => @dir)

      @pagy, @users = pagy(scope)
    end

    def toggle_admin
      if @user == current_user
        redirect_to admin_users_path, alert: "自分自身の管理者権限は変更できません。"
        return
      end

      @user.update!(admin: !@user.admin?)
      status = @user.admin? ? "付与" : "解除"
      redirect_to admin_users_path, notice: "#{@user.email} の管理者権限を#{status}しました。"
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
