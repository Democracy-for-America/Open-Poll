class Poll < ActiveRecord::Base
  has_many :candidates
  has_many :votes

  validates :title, presence: true
  validates :name, presence: true
  validates :short_name, presence: true, format: {with: /\A[a-zA-Z0-9-]+\z/, message: "only allows letters, numbers and dashes" }

  has_attached_file :facebook_image
  validates_attachment :facebook_image, content_type: { content_type: /\Aimage\/.*\Z/ }

  # Used on vote confirmation page to display top three candidates
  def results
    candidates = Candidate.find_by_sql("
      SELECT
        candidates.name AS first_choice,
        candidates.*,
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM votes WHERE poll_id = #{self.id}) AS percent
      FROM
        votes, candidates
      WHERE
        candidates.poll_id = #{self.id} AND
        votes.poll_id = #{self.id} AND
        LOWER(votes.first_choice) = LOWER(candidates.name) AND
        candidates.show_in_results = true
      GROUP BY
        candidates.id
      ORDER BY COUNT(*) DESC
      LIMIT 5
    ")
  end

  # Used to generate intital bar graph display when results page is loaded,
  # before a user has eliminated any candidates from the running.
  def initial_results
    Candidate.find_by_sql("
      SELECT
      c.*,
      CASE
      WHEN c.id IS NOT NULL
        THEN c.name
      ELSE
        'Other'
      END AS top_choice,
      COUNT(*) AS total
      FROM
      (
        SELECT
        CASE
        WHEN first_choice <> ''
          THEN first_choice
        WHEN second_choice <> ''
          THEN second_choice
        WHEN third_choice <> ''
          THEN third_choice
        ELSE NULL
        END AS corrected_top_choice
        FROM votes
        WHERE votes.poll_id = #{self.id}
      ) AS corrected_votes
      LEFT JOIN candidates c ON
        LOWER(c.name) = LOWER(corrected_votes.corrected_top_choice) AND
        c.show_in_results = true AND
        c.poll_id = #{self.id}
      WHERE corrected_votes.corrected_top_choice IS NOT NULL
      GROUP BY c.id
      ORDER BY c.name IS NULL, COUNT(*) DESC
    ")
  end

  # Used to add votes to runner-ups when candidates are eliminated from the running
  # For Postgres, use:
  #   STRING_AGG(CONCAT(runner_up, ':', gain), ';') AS gains
  # in replace of
  #   GROUP_CONCAT(CONCAT(runner_up, ':', gain) SEPERATOR ';') AS gains
  def runoff_results
    Vote.find_by_sql("
      SELECT
        eliminated_candidate_1,
        eliminated_candidate_2,
        GROUP_CONCAT(CONCAT(runner_up, ':', gain) SEPARATOR ';') AS gains
      FROM
      (
        SELECT eliminated_candidate_1, eliminated_candidate_2, runner_up, COUNT(*) AS gain FROM
        (
          SELECT
            CASE WHEN eliminated_candidate_2 IS NOT NULL THEN LEAST(eliminated_candidate_1, eliminated_candidate_2) ELSE eliminated_candidate_1 END AS eliminated_candidate_1,
            CASE WHEN eliminated_candidate_1 <> eliminated_candidate_2 THEN GREATEST(eliminated_candidate_1, eliminated_candidate_2) ELSE NULL END AS eliminated_candidate_2,
            runner_up
          FROM
          (
            SELECT
              CASE WHEN eliminated_candidate_1 IN (SELECT name FROM candidates WHERE poll_id = #{self.id} AND show_in_results = true) THEN eliminated_candidate_1 ELSE 'Other' END AS eliminated_candidate_1,
              CASE WHEN eliminated_candidate_2 IS NULL OR eliminated_candidate_2 IN (SELECT name FROM candidates WHERE poll_id = #{self.id} AND show_in_results = true) THEN eliminated_candidate_2 ELSE 'Other' END AS eliminated_candidate_2,
              CASE WHEN runner_up IN (SELECT name FROM candidates WHERE poll_id = #{self.id} AND show_in_results = true) THEN runner_up ELSE 'Other' END AS runner_up
            FROM
            (
              SELECT * FROM (
                SELECT
                  CASE WHEN first_choice <> '' THEN first_choice ELSE second_choice END AS eliminated_candidate_1,
                  NULL AS eliminated_candidate_2,
                  CASE WHEN first_choice <> '' AND second_choice <> '' THEN second_choice ELSE third_choice END AS runner_up
                FROM votes
                WHERE
                  poll_id = #{self.id}
              ) AS q
              WHERE
                eliminated_candidate_1 <> '' AND
                runner_up <> ''
              UNION ALL
              SELECT
                first_choice AS eliminated_candidate_1,
                second_choice AS eliminated_candidate_2,
                third_choice AS runner_up
              FROM votes
              WHERE
                poll_id = #{self.id} AND
                first_choice <> '' AND
                second_choice <> '' AND
                third_choice <> ''
            ) AS runoffs
          ) AS corrected_runoffs
          WHERE runner_up NOT IN (eliminated_candidate_1, COALESCE(eliminated_candidate_2, ''))
        ) AS runoff_results
        GROUP BY eliminated_candidate_1, eliminated_candidate_2, runner_up
      ) AS full_results
      GROUP BY eliminated_candidate_1, eliminated_candidate_2
    ")
  end  
end
