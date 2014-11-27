module TaskHelper
  def errors_field_for_task_or_exercise(field)
    if @exercise_task
      errors_for_field(@exercise_task, field)
    else
      errors_for_field(@task, field)
    end
  end
end