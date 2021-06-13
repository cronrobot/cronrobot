class Scheduler < ApplicationRecord
  belongs_to :project

  encrypts :command

  
end
