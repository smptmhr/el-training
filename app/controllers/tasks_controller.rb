class TasksController < ApplicationController
  before_action :logged_in_user
  TASKS_NUM_PER_PAGE = 10

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = @current_user.tasks.build(task_params)
    if @task.save
      flash[:success] = I18n.t 'task_create_success'
      redirect_to tasks_url
    else
      flash.now[:danger] = I18n.t 'task_create_failed'
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @task = find_task_with_err_handling(params[:id])
  end

  def index
    # 現在ログイン中のユーザのタスクを取得
    tasks = current_user.tasks.preload(:category, :labels).all # N+1対策でpreloadを使用

    # タスクの検索
    searched_tasks = tasks.search_task(params[:search], params[:search_option])
    current_search_item_status

    # タスクのフィルタリング
    current_filter_params
    filtered_tasks = searched_tasks.filter_from_checkbox(filter_params_all_blank?, @filter_priority, @filter_progress)

    current_label_filter
    filtered_by_label = filtered_tasks.filter_by_label(params[:label_id])

    # タスクのソート(デフォルトは作成日の昇順)
    current_sorting_params
    sorted_tasks = filtered_by_label.order("#{@sort_by} #{@direction}")

    # ページネーション
    @tasks = sorted_tasks.page(params[:page]).per(TASKS_NUM_PER_PAGE)
  end

  def destroy
    @task = find_task_with_err_handling(params[:id])

    if @task.destroy
      flash[:success] = I18n.t 'task_delete_success'
      redirect_to tasks_url
    else
      flash.now[:danger] = I18n.t 'task_delete_failed'
      render turbo_stream: turbo_stream.update('flash', partial: 'shared/flash')
      redirect_to @task
    end
  end

  def edit
    @task = find_task_with_err_handling(params[:id])
  end

  def update
    @task = find_task_with_err_handling(params[:id])
    if @task.update(task_params)
      flash[:success] = I18n.t 'task_update_success'
      redirect_to @task
    else
      flash.now[:danger] = I18n.t 'task_update_failed'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(
      :name,
      :category_id,
      :description,
      :start_date,
      :necessary_days,
      :progress,
      :priority,
      { label_ids: [] }
    )
  end

  def find_task_with_err_handling(task_id)
    task = Task.find_by(id: task_id)
    if task.blank?
      flash[:danger] = I18n.t 'task_not_exist'
      redirect_to root_url
    elsif task.user != @current_user
      flash[:danger] = I18n.t 'permission denied'
      redirect_to root_url
    else
      task
    end
  end

  def current_search_item_status
    @shown_search_placeholder = params[:search].presence || 'タスク名'
    @shown_search_option = params[:search_option].presence || 'perfect_match'
  end

  def current_filter_params
    if filter_params_all_blank?
      # 検索項目が空のとき、全ての項目にチェックを入れる
      @filter_priority = Task.priorities
      @filter_progress = Task.progresses
    else
      # 見つからなければnil
      @filter_priority = params.dig(:filter, :priority)
      @filter_progress = params.dig(:filter, :progress)
    end
  end

  def current_label_filter
    label = Label.find_by(id: params[:label_id])
    @filter_label = label&.name.presence || '選択してください'
  end

  def current_sorting_params
    @sort_by      = params[:sort].presence      || 'created_at'
    @direction    = params[:direction].presence || 'ASC'
  end

  def filter_params_all_blank?
    params.dig(:filter, :priority).blank? && params.dig(:filter, :progress).blank?
  end
end
