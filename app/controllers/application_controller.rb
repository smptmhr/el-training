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
end
