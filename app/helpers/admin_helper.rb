module AdminHelper
  def admin_user_exist?
    user = User.find(params[:id])
    admin_user_num = User.where(role: '管理').size

    return unless (admin_user_num == 1) && (user.role == '管理')

    flash[:danger] = I18n.t 'admin_user_must_exist'
    redirect_to request.referer
  end
end
