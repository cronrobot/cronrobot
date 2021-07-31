
class SchedulerSocketPing < Scheduler

  def celery_task
    "celery_admin.celery.socket_ping"
  end

  def plural_path_name
    "scheduler_socket_pings"
  end

end
