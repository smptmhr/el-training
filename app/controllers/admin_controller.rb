class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user?

  include TasksHelper
  def index
    # preloadを使用してN+1問題に対応
    @users = User.preload(:categories, :tasks).all
  end

  def show
    # preloadを使用してN+1問題に対応
    @user = User.preload(:categories, :tasks).find(params[:id])
  end

  private

  def admin_user?
    return unless current_user.role != '管理ユーザ'

    flash[:danger] = I18n.t 'permission_denied'
    redirect_to root_url
  end
end
