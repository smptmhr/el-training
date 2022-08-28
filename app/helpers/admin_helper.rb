module AdminHelper
  def admin_user_exist?
    user = User.find(params[:id])
    admin_user_num = User.where(role: '管理').size

    return unless (admin_user_num == 1) && (user.role == '管理')

    flash[:danger] = '管理ユーザが0人になってしまうため、その操作はできません。'
    redirect_to request.referer
  end
end
