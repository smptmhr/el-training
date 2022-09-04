class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update show destroy)
  before_action :check_user_permission, only: %i(edit update show)
  before_action :admin_user_exist?, only: :destroy
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = I18n.t 'send_activation_email'
      redirect_to root_url
    else
      flash.now[:danger] = I18n.t 'user_create_failed'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = I18n.t 'user_update_success'
      redirect_to tasks_url
    else
      flash.now[:danger] = I18n.t 'user_update_failed'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    # category has many tasks, dependent: :restrict_with_error につき
    # タスクを持つカテゴリは削除できないため、タスクを先に削除する
    @user.categories.each do |c|
      c.task.destroy_all
    end

    if @user.destroy
      flash[:success] = I18n.t 'user_delete_success'
    else
      flash[:danger] = I18n.t 'user_delete_failed'
    end

    # 管理ユーザ → ユーザ管理一覧
    # 一般ユーザ → root_url
    if current_user.role == '管理'
      redirect_to admin_index_url
    else
      redirect_to root_url
    end
  end

  private

  def user_params
    params.require(:user).permit(:name,
                                 :email,
                                 :password,
                                 :password_confirmation)
  end

  # 自分以外のユーザ情報の編集を許可しない
  def check_user_permission
    user_to_edit = User.find(params[:id])
    return if user_to_edit == current_user # 権限あり

    flash[:danger] = I18n.t 'permission denied' # 異なるユーザ、権限なし
    redirect_to root_url
  end
end
