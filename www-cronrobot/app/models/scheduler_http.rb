
class SchedulerHttp < Scheduler

  def celery_task
    "celery_admin.celery.http"
  end

end
