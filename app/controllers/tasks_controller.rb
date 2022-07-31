class TasksController < ApplicationController
  TASKS_NUM_PER_PAGE = 10

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
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
    # タスクの検索
    searched_tasks = Task.search_task(params[:search], params[:search_option])
    @shown_search_placeholder = params[:search].presence || 'タスク名'
    @shown_search_option = params[:search_option].presence || 'perfect_match'

    # タスクのフィルタリング
    update_filter_params
    filtered_tasks = filter_tasks_from_checkbox_params(searched_tasks)

    # タスクのソート(デフォルトはidの昇順)
    sort_by      = params[:sort].presence      || 'id'
    direction    = params[:direction].presence || 'ASC'
    sorted_tasks = filtered_tasks.order("#{sort_by} #{direction}")
    @tasks       = sorted_tasks.page(params[:page]).per(TASKS_NUM_PER_PAGE)
  end

  def destroy
    @task = find_task_with_err_handling(params[:id])

    if @task.destroy
      flash[:success] = I18n.t 'task_delete_success'
      redirect_to tasks_url
    else
      flash[:danger] = I18n.t 'task_delete_failed'
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
      :description,
      :start_date,
      :necessary_days,
      :progress,
      :priority
    )
  end

  def find_task_with_err_handling(task_id)
    task = Task.find_by(id: task_id)
    if task.blank?
      flash[:danger] = I18n.t 'task_not_exist'
      return redirect_to tasks_url
    end
    task
  end

  def update_filter_params
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

  def filter_tasks_from_checkbox_params(tasks)
    if filter_params_all_blank? # indexページに遷移直後 or チェックボックスが空のとき
      tasks.all
    else
      tasks.where(priority: @filter_priority, progress: @filter_progress)
    end
  end

  def filter_params_all_blank?
    params.dig(:filter, :priority).blank? && params.dig(:filter, :progress).blank?
  end
end
