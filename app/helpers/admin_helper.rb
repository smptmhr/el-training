module AdminHelper
  def admin_user_exist?
    user = User.find(params[:id])
    admin_user_num = User.where(role: :admin).size

    return unless (admin_user_num == 1) && user.role_admin?

    flash[:danger] = I18n.t 'admin_user_must_exist'
    redirect_to request.referer
  end
end
