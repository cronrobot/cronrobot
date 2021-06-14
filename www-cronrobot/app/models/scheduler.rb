class Scheduler < ApplicationRecord
  belongs_to :project
  has_many :resources,
           foreign_key: :reference_id,
           class_name: :ResourceScheduler,
           dependent: :destroy
  
end
