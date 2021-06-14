
class ResourceScheduler < Resource
  belongs_to :scheduler, foreign_key: :reference_id
end
