class Poll < ActiveRecord::Base
  has_many :candidates

  validates :title, presence: true
  validates :short_name, presence: true, format: {with: /\A[a-zA-Z-]+\z/, message: "only allows letters, numbers and dashes" }

  has_attached_file :facebook_image
  validates_attachment :facebook_image, content_type: { content_type: /\Aimage\/.*\Z/ }
end
