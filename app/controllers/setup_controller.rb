class SetupController < ApplicationController
  skip_before_action :require_setup_completed
  before_action :redirect_if_setup_completed

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = true

    if @user.save
      sign_in(@user)
      redirect_to root_path, notice: "管理者アカウントを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def redirect_if_setup_completed
    redirect_to root_path if User.exists?
  end
end
