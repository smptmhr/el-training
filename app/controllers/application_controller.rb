class ApplicationController < ActionController::Base
  include SessionsHelper

  # ユーザがログインしているか確認
  def logged_in_user
    return if logged_in?

    flash[:danger] = I18n.t 'login_required'
    redirect_to login_url
  end

  def admin_user_exist?
    user = User.find(params[:id])
    admin_user_num = User.where(role: :admin).size

    return unless (admin_user_num == 1) && user.role_admin?

    flash[:danger] = I18n.t 'admin_user_must_exist'
    redirect_to request.referer
  end

  # rubocop:disable Naming/VariableNumber
  # 例外処理
  unless Rails.env.development?
    rescue_from Exception,                      with: :render_500
    rescue_from ActiveRecord::RecordNotFound,   with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
  end

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def render_404
    render 'error/404', status: :not_found
  end

  def render_422
    render 'error/422', status: :unprocessable_entity
  end

  def render_500
    render 'error/500', status: :internal_server_error
  end
  # rubocop:enable Naming/VariableNumber
end
