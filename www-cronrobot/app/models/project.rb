class Project < ApplicationRecord
  has_many :schedulers, dependent: :destroy
  belongs_to :user

  has_many :resources,
           foreign_key: :reference_id,
           class_name: :ResourceProject,
           dependent: :destroy
  has_many :notification_channels, dependent: :destroy

  validates :name, presence: true

  after_destroy :process_destroy

  def process_destroy
    Grafana.destroy_folder(self)
  end
end
