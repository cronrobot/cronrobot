
class ResourceScheduler < Resource
  belongs_to :scheduler, foreign_key: :reference_id

  validates :scheduler, presence: true
end
