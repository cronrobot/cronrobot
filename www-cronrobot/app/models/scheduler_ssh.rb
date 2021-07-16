
class SchedulerSsh < Scheduler

  def celery_task
    "celery_admin.celery.ssh"
  end

end
