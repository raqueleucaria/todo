class Task < ApplicationRecord
    belongs_to :parent, class_name: "Task", optional: true
    has_many :subtasks, class_name: "Task", foreign_key: "parent_id", dependent: :destroy
    validates :description, presence: true
    validate :prevent_deep_nesting

    # Callbacks para gerenciar lógica de subtarefas
    after_update :handle_completion_logic
    after_create :handle_parent_completion_on_create

    # Scope para tarefas principais
    scope :main_tasks, -> { where(parent_id: nil) }

    private

    def prevent_deep_nesting
        if parent.present? && parent.parent.present?
            errors.add(:base, "Subtasks cannot be nested more than one level deep")
        end
    end

    def handle_completion_logic
        return unless saved_change_to_completed?

        if parent_id.nil?
            # Tarefa principal foi marcada/desmarcada
            handle_main_task_completion
        else
            # Subtarefa foi marcada/desmarcada
            handle_subtask_completion
        end
    end

    def handle_main_task_completion
        if completed?
            # Marcar todas as subtarefas como concluídas
            subtasks.update_all(completed: true)
        end
    end

    def handle_subtask_completion
        return unless parent

        if completed?
            # Verificar se todas as subtarefas estão concluídas
            if parent.subtasks.all?(&:completed?)
                parent.update_column(:completed, true)
            end
        else
            # Se uma subtarefa foi desmarcada, desmarcar a tarefa principal
            if parent.completed?
                parent.update_column(:completed, false)
            end
        end
    end

    def handle_parent_completion_on_create
        # Se uma nova subtarefa for adicionada a uma tarefa principal concluída,
        # desmarcar a tarefa principal
        if parent&.completed?
            parent.update_column(:completed, false)
        end
    end
end
