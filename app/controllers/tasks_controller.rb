class TasksController < ApplicationController
  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params) # TODO: strong parameter
    if @task.save
      redirect_to @task
    else
      render 'new'
    end
  end

  private

  def task_params
    params.require(:task).permit(:task_name,  :abstract_text,
                                 :start_date, :deadline_date, :status)
  end
end
