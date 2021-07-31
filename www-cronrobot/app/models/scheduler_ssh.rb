
class SchedulerSsh < Scheduler

  def celery_task
    "celery_admin.celery.ssh"
  end

  def plural_path_name
    "scheduler_sshes"
  end

  def store_params
    store_params_from_template
  end

end
