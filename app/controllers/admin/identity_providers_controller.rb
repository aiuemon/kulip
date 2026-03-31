module Admin
  class IdentityProvidersController < BaseController
    # プロバイダータイプごとの許可される settings キー
    SAML_SETTINGS_KEYS = %w[idp_sso_url idp_slo_url idp_cert].freeze
    OIDC_SETTINGS_KEYS = %w[issuer client_id client_secret redirect_uri].freeze

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

    def parse_saml_metadata
      result = if params[:metadata_file].present?
        SamlMetadataParser.parse_xml(params[:metadata_file].read)
      elsif params[:metadata_url].present?
        SamlMetadataParser.fetch_and_parse(params[:metadata_url])
      else
        SamlMetadataParser::Result.new(success?: false, error: "メタデータファイルまたは URL を指定してください")
      end

      if result.success?
        render json: { success: true, data: result.data }
      else
        render json: { success: false, error: result.error }, status: :unprocessable_entity
      end
    end

    def restart_app
      if Rails.env.development?
        # tmp/restart.txt をタッチして再起動をトリガー
        FileUtils.touch(Rails.root.join("tmp/restart.txt"))

        # Puma を再起動（バックグラウンドで新しいサーバーを起動し、現在のプロセスを終了）
        pid = spawn("cd #{Rails.root} && sleep 1 && bin/rails server -p 3000", [ :out, :err ] => "/dev/null")
        Process.detach(pid)

        # 現在のサーバーを終了
        Thread.new { sleep 0.5; Process.kill("TERM", Process.pid) }
      end

      redirect_to admin_identity_providers_path,
        notice: "アプリを再起動中です。3秒後に自動でリロードします。"
    end

    def update_saml_sp_entity_id
      Setting.saml_sp_entity_id = params[:saml_sp_entity_id].to_s.strip
      redirect_to admin_identity_providers_path,
        notice: "SP エンティティ ID を更新しました。設定を反映するにはアプリを再起動してください。"
    end

    private

    def set_identity_provider
      @identity_provider = IdentityProvider.find(params[:id])
    end

    def identity_provider_params
      permitted = params.require(:identity_provider).permit(
        :provider_type, :name, :slug, :enabled, :show_on_login
      )

      # settings をホワイトリスト形式でフィルタリング
      if params[:identity_provider][:settings].present?
        permitted[:settings] = filter_settings_params
      end

      permitted
    end

    def filter_settings_params
      provider_type = params[:identity_provider][:provider_type]
      whitelist = settings_whitelist_for(provider_type)

      params[:identity_provider][:settings]
        .to_unsafe_h
        .slice(*whitelist)
        .transform_values { |v| v.is_a?(String) ? v.strip : v }
    end

    def settings_whitelist_for(provider_type)
      case provider_type
      when "saml" then SAML_SETTINGS_KEYS
      when "oidc" then OIDC_SETTINGS_KEYS
      else []
      end
    end
  end
end
