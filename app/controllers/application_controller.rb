class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_setup_completed
  before_action :authenticate_user!

  private

  def require_setup_completed
    redirect_to new_setup_path unless User.exists?
  end
end
