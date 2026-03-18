Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  # 初回セットアップ
  resource :setup, only: %i[new create], controller: "setup"

  # ダッシュボード（ルート）
  root "dashboard#index"

  # 画像グループ
  resources :image_groups, only: %i[index show new create destroy] do
    member do
      get :download
    end
  end

  # 画像（グループ内）
  resources :images, only: %i[show destroy] do
    member do
      post :retry
      get :download
    end
  end

  # 管理者画面
  namespace :admin do
    resources :identity_providers do
      collection do
        post :restart_app
      end
    end
    resource :auth_settings, only: %i[show update]
    resource :ocr_settings, only: %i[show update]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
