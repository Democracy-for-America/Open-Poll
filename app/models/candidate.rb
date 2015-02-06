class Candidate < ActiveRecord::Base
  belongs_to :poll

  validates :name, presence: true

  has_attached_file :image, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "unnamed.png"
  validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }
end
