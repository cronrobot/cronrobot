class Scheduler < ApplicationRecord
  belongs_to :project
  has_many :resources,
           foreign_key: :reference_id,
           class_name: :ResourceScheduler,
           dependent: :destroy

  before_update :upsert_celery_periodic_task
  before_destroy :delete_celery_periodic_task

  def touch!
    upsert_celery_periodic_task
    touch
  end

  def celery_api_url(path)
    base_url = Rails.application.credentials.dig(:celery_api, :base_url)

    "#{base_url}#{path}"
  end

  def celery_periodic_task_name
    "scheduler-#{id}"
  end

  def celery_task
    raise "not implemented"
  end

  def celery_get(path)
    HTTParty.get(celery_api_url(path))
  end

  def celery_post(path, body)
    HTTParty.post(celery_api_url(path), body: body)
  end

  def celery_delete(path)
    HTTParty.delete(celery_api_url(path))
  end

  def celery_periodic_task_exists?
    celery_get("/periodic-tasks/find?name=#{celery_periodic_task_name}").code == 200
  end

  def upsert_celery_periodic_task
    if celery_periodic_task_exists?
      # update
    else
      body = {
        name: celery_periodic_task_name,
        task: celery_task,
        schedule: schedule,
        resource_id: resources.first&.id
      }

      celery_post("/periodic-tasks/", body)
    end
  end

  def delete_celery_periodic_task
    if celery_periodic_task_exists?
      celery_delete("/periodic-tasks/#{celery_periodic_task_name}/")
    end
  end

end
