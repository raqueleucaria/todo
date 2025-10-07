class TasksController < ApplicationController
  before_action :set_task, only: %i[update destroy toggle]

  def index
    @tasks = Task.where(parent_id: nil)
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_url, notice: "Tarefa criada com sucesso." }
        # --- ALTERAÇÃO IMPORTANTE ---
        # Esta linha diz ao Rails para procurar e renderizar o ficheiro
        # 'create.turbo_stream.erb' quando o formulário for submetido via Turbo.
        format.turbo_stream
      else
        @tasks = Task.where(parent_id: nil)
        # Se houver um erro de validação, renderiza o formulário novamente com os erros.
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to tasks_url, notice: "Tarefa atualizada com sucesso." }
        format.turbo_stream # Renderiza update.turbo_stream.erb
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@task), partial: "task", locals: { task: @task }) }
      end
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Tarefa apagada com sucesso." }
      format.turbo_stream # Renderiza destroy.turbo_stream.erb
    end
  end

  def toggle
    @task.update!(completed: params[:completed])

    respond_to do |format|
      format.json { render json: { message: "Success" } }
      format.turbo_stream do
        # Renderizar atualizações para a tarefa atual e relacionadas
        render turbo_stream: build_toggle_turbo_streams
      end
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:description, :completed, :parent_id)
  end

  # CORREÇÃO 2: Método para construir Turbo Streams quando uma tarefa é marcada/desmarcada
  # Atualiza a tarefa atual e todas as tarefas relacionadas (pai/filhas) conforme as regras de negócio
  def build_toggle_turbo_streams
    streams = []

    # Atualizar a tarefa atual
    streams << turbo_stream.replace(dom_id(@task), partial: "task", locals: { task: @task })

    if @task.parent_id.nil?
      # Se é tarefa principal, atualizar todas as subtarefas (que foram alteradas pelos callbacks)
      @task.subtasks.reload.each do |subtask|
        streams << turbo_stream.replace(dom_id(subtask), partial: "task", locals: { task: subtask })
      end
    else
      # Se é subtarefa, atualizar a tarefa principal (que pode ter sido alterada pelos callbacks)
      parent = @task.parent.reload
      streams << turbo_stream.replace(dom_id(parent), partial: "task", locals: { task: parent })
    end

    streams
  end
end
