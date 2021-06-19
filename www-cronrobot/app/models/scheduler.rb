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

  def celery_task
    raise "not implemented"
  end

  def upsert_celery_periodic_task
    Celery.upsert_periodic_task(self)
  end

  def delete_celery_periodic_task
    if Celery.periodic_task_exists?(id)
      Celery.delete("/periodic-tasks/#{Celery.periodic_task_name(id)}/")
    end
  end

end
