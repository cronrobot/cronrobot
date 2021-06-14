
class ResourceProject < Resource
  belongs_to :project, foreign_key: :reference_id
end
