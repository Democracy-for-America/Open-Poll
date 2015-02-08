class Poll < ActiveRecord::Base
  has_many :candidates

  validates :title, presence: true
  validates :short_name, presence: true, format: {with: /\A[a-zA-Z-]+\z/, message: "only allows letters, numbers and dashes" }

  has_attached_file :facebook_image
  validates_attachment :facebook_image, content_type: { content_type: /\Aimage\/.*\Z/ }

  # Used on vote confirmation page to display top three candidates
  def results
    candidates = Candidate.find_by_sql("
      SELECT
        candidates.name AS first_choice,
        candidates.*,
        COUNT(*) / (SELECT COUNT(*) FROM votes WHERE poll_id = #{self.id}) AS percent
      FROM
        votes, candidates
      WHERE
        candidates.poll_id = #{self.id} AND
        votes.poll_id = #{self.id} AND
        votes.first_choice = candidates.name AND
        candidates.show_in_results = true
      GROUP BY
        candidates.id
    ")
  end
end
