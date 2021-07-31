
class SchedulerHttp < Scheduler

  def celery_task
    "celery_admin.celery.http"
  end

  def plural_path_name
    "scheduler_https"
  end

end
