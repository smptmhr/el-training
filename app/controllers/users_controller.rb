class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update show destroy index)
  before_action :check_user_permission,   only: %i(edit update show)
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = I18n.t 'user_create_success'
      Category.create(name: Category::DEFAULT_CREATED_CATEGORY, user: @user)
      log_in @user
      redirect_to tasks_url
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

    if @user.destroy
      flash[:success] = I18n.t 'user_delete_success'
    else
      flash[:danger] = I18n.t 'user_delete_failed'
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name,
                                 :email,
                                 :password,
                                 :password_confirmation)
  end

  # ログイン中のユーザが正しいか確認
  def check_user_permission
    user_to_edit = User.find(params[:id])
    if user_to_edit != current_user # 正しくないユーザ
      flash[:danger] = I18n.t 'permission denied'
      redirect_to root_url
    end
  end
end
