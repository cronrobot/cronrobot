
namespace :schedulers do
  

  desc ''
  task pause_all: :environment do
    name = "Task schedulers__pause_all"
    Rails.logger.info "[#{name}] begin"
    
      Scheduler.all.each do |scheduler|
        begin
          Rails.logger.info "[#{name}] pausing scheduler #{scheduler.id}..."
          
          if scheduler.pause_state != "manual"
            scheduler.pause!
          end
        rescue StandardError => e
          Rails.logger.error "[#{name}] failed to pause scheduler #{scheduler.id} error = #{e}"
        end
      end
  end

  desc ''
  task resume_all: :environment do
    name = "Task schedulers__resume_all"
    Rails.logger.info "[#{name}] begin"
    
      Scheduler.all.each do |scheduler|
        begin
          Rails.logger.info "[#{name}] resuming scheduler #{scheduler.id}..."

          if scheduler.pause_state != "manual"
            scheduler.unpause!
          end
        rescue StandardError => e
          Rails.logger.error "[#{name}] failed to resume scheduler #{scheduler.id} error = #{e}"
        end
      end
  end
end
