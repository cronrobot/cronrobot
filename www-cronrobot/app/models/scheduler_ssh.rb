
class SchedulerSsh < Scheduler

  def celery_task
    "celery_admin.celery.ssh"
  end

  def store_params
    if self.params.present?
      if resources.exists?
        resource = resources.first

        
        resource.params = params
        
        resource.save
      else
        klass = "Resource#{self.type}".constantize
        resource = klass.create(reference_id: id, params: params)
      end
      
      errors.add(:params, "Invalid parameters: #{resource.errors.full_messages}") unless resource.valid?
    end
  end

end
