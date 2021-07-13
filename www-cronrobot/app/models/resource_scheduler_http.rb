
class ResourceSchedulerHttp < ResourceScheduler
  def expected_scheduler_type
    "SchedulerHttp"
  end

  def expected_required_params
    ["url"]
  end
end
