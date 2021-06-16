
class SchedulerSocketPing < Scheduler

  def celery_task
    "celery_admin.celery.socket_ping"
  end

end
