
class Celery
  def self.api_url(path)
    base_url = Rails.application.credentials.dig(:celery_api, :base_url)

    "#{base_url}#{path}"
  end

  def self.periodic_task_name(id)
    "scheduler-#{id}"
  end

  def self.get(path)
    HTTParty.get(Celery.api_url(path))
  end

  def self.post(path, body)
    HTTParty.post(Celery.api_url(path), body: body)
  end

  def self.delete(path)
    HTTParty.delete(Celery.api_url(path))
  end

  def self.periodic_task_exists?(id)
    Celery.get("/periodic-tasks/find?name=#{Celery.periodic_task_name(id)}").code == 200
  end

  def self.upsert_periodic_task(scheduler)
    body = {
      name: Celery.periodic_task_name(scheduler.id),
      task: scheduler.celery_task,
      schedule: scheduler.schedule,
      resource_id: scheduler.resources.first&.id
    }

    result = Celery.post("/periodic-tasks/", body)

    raise Exception, "#{result.body}" if result.code != 200 
  end
end