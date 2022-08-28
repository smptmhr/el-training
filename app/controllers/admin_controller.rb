class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user?
  before_action :admin_user_exist?, only: :update

  include TasksHelper
  def index
    # preloadを使用してN+1問題に対応
    @users = User.preload(:categories, :tasks).all.order(:id)
  end

  def show
    # preloadを使用してN+1問題に対応
    @user = User.preload(:categories, :tasks).find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    # 管理→一般 or 一般→管理
    changed_role = (@user.role == '管理' ? '一般' : '管理')
    if @user.update(role: changed_role)
      flash[:success] = I18n.t 'user_update_success'
    else
      flash[:danger] = I18n.t 'user_update_failed'
    end

    redirect_to admin_path(@user)
  end

  private

  def admin_user?
    return unless current_user.role != '管理'

    flash[:danger] = I18n.t 'permission_denied'
    redirect_to root_url
  end

  def admin_user_exist?
    user = User.find(params[:id])
    admin_user_num = User.where(role: '管理').size

    return unless (admin_user_num == 1) && (user.role == '管理')
    flash[:danger] = '管理ユーザが0人になってしまうため、区分を変更できません'
    redirect_to admin_path(user)
  end
end
