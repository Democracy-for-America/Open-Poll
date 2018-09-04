class Candidate < ActiveRecord::Base
  belongs_to :poll

  validates :name, presence: true

  scope :visible, -> { where(show_on_ballot: true) }

  has_attached_file :image, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "unnamed.png",
    path: "open-poll/:class/:attachment/:id_partition/:style/:filename"
  validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }

  before_save :set_slug

  def set_slug
    self.slug = self.name.parameterize
  end

  def to_param
    [self.id, self.name.parameterize].join("-")
  end
end
