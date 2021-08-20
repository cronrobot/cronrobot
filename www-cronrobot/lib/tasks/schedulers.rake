
namespace :schedulers do
  

  desc ''
  task pause_all: :environment do
    name = "Task schedulers__pause_all"
    Rails.logger.info "[#{name}] begin"

    
      Scheduler.all.each do |scheduler|
        begin
          Rails.logger.info "[#{name}] pausing scheduler #{scheduler.id}..."
          scheduler.pause!
        rescue StandardError => e
          Rails.logger.error "[#{name}] failed to pause scheduler #{scheduler.id} error = #{e}"
          puts e
        end
      end
  end
end
