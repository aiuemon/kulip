module Admin
  class IdentityProvidersController < BaseController
    before_action :set_identity_provider, only: %i[show edit update destroy]

    def index
      @identity_providers = IdentityProvider.order(:provider_type, :name)
    end

    def show
    end

    def new
      @identity_provider = IdentityProvider.new(
        provider_type: params[:provider_type] || "saml",
        settings: {}
      )
    end

    def edit
    end

    def create
      @identity_provider = IdentityProvider.new(identity_provider_params)

      if @identity_provider.save
        redirect_to admin_identity_providers_path,
          notice: "IdP を作成しました。設定を反映するにはアプリを再起動してください。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @identity_provider.update(identity_provider_params)
        redirect_to admin_identity_providers_path,
          notice: "IdP を更新しました。設定を反映するにはアプリを再起動してください。"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @identity_provider.destroy
      redirect_to admin_identity_providers_path,
        notice: "IdP を削除しました。設定を反映するにはアプリを再起動してください。"
    end

    private

    def set_identity_provider
      @identity_provider = IdentityProvider.find(params[:id])
    end

    def identity_provider_params
      permitted = params.require(:identity_provider).permit(
        :provider_type, :name, :slug, :enabled, :show_on_login
      )

      # settings をネストしたパラメータから取得
      if params[:identity_provider][:settings].present?
        permitted[:settings] = params[:identity_provider][:settings].to_unsafe_h
      end

      permitted
    end
  end
end
