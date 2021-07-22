
class ResourceProject < Resource
  belongs_to :project, foreign_key: :reference_id

  validates :project, presence: true
  validates :sub_type, presence: true

  validates :sub_type, :inclusion => {:in => %w(ResourceProjectSsh )}

end
