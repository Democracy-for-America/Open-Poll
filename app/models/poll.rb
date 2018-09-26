class Poll < ActiveRecord::Base
  has_many :candidates
  has_many :votes

  validates :title, presence: true
  validates :short_name, presence: true, format: {with: /\A[a-zA-Z0-9-]+\z/, message: "only allows letters, numbers and dashes" }

  has_attached_file :facebook_image
  validates_attachment :facebook_image, content_type: { content_type: /\Aimage\/.*\Z/ }

  has_attached_file :logo, default_url: "dfa_clear.png"
  validates_attachment :logo, content_type: { content_type: /\Aimage\/.*\Z/ }

  # Create a poll with pre-filled fields
  def self.new_with_defaults
    @poll = Poll.new
    @poll.title          =  'PULSE POLL: WHO SHOULD RUN?'
    @poll.subtitle       =  'Choose your top 3 draft picks'
    @poll.donation_url   =  'https://secure.actblue.com/contribute/page/democracyforamericacontribute'
    @poll.instructions   =  'Drag and drop your top choices for the [POLL NAME] from the list below into this area.'
    @poll.results_text   =  'Democracy for America members cast [TOTAL VOTES] votes for up to three favorite potential candidates in DFA\'s [POLL NAME]. Curious how the final results might look with or without specific candidates included in various primary scenarios? <strong>Just click on any candidate to remove (or add) them to the results.</strong>'
    @poll.results_page_og_description = 'Curious how DFA\'s member poll might look with or without potential candidates? Just click on any candidate to remove (or add) them to the final results!'
    @poll.results_page_og_title = 'FINAL RESULTS: Democracy for America\'s [POLL NAME]'
    @poll.vote_page_og_description = 'Find out who I voted for in Democracy for America\'s [POLL NAME], and submit your top picks!'
    @poll.vote_page_og_title = 'My top pick is...'
    @poll.twitter_text = 'Find out who I voted for in Democracy for America\'s [POLL NAME], and submit your top picks!'
    @poll.from_line = '"DFA Pulse Poll Team" <info@democracyforamerica.com>'
    @poll.email_template =
'<p id="notice">{{ first_name }} –</p>
<p>Thank you for submitting your vote in Democracy for America\'s [POLL NAME]!</p>
<p>Your top pick, {{ top_candidate }}, is currently in {{ rank }} place!</p>
<p><strong>Now you can help your favorite candidate win by spreading the word and sharing your vote with your friends.</strong></p>
<p><strong><a href="{{ facebook_url }}", target: "_blank">Post to Facebook</a></strong></p>
<p><strong><a href="{{ twitter_url }}" target="_blank">Share on Twitter</a></strong></p>
<p>
<strong>Or copy and paste this link to your top pick into an email:<br>
{{ share_url }}</strong>
</p>
<p>DFA’s [POLL NAME] will end on <strong>[DATE], at [TIME]</strong>. We will announce the results later that week. </p>
<p>
<strong><a href=\'https://secure.actblue.com/contribute/page/democracyforamericacontribute\'>Please chip in $3 to help Democracy for America\'s work to amplify your voice in the [UPCOMING ELECTION].</a></strong>
</p>
<p>Thanks so much. Together, we will work to make sure the strongest possible candidate wins the [UPCOMING ELECTION] -- and goes on to win the [OFFICE].</p>
<p>- The DFA Pulse Poll Team</p>'
    return @poll
  end

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

  # Intended for internal display
  def raw_results
    total = self.votes.count

    Vote.find_by_sql("
      SELECT
        v.first_choice,
        c.id AS candidate_id,
        COUNT(DISTINCT v.id) AS votes,
        COUNT(DISTINCT v.ip_address) AS distinct_ip_addresses,
        COUNT(DISTINCT v.session_cookie) AS distinct_session_cookies,
        SUM(verified_auth_token <> 1) AS unverified_auth_tokens,
        (SELECT COUNT(DISTINCT w.id) FROM votes w WHERE v.poll_id = w.poll_id AND (v.first_choice = w.first_choice OR v.first_choice = w.second_choice OR v.first_choice = w.third_choice)) AS all_votes
      FROM votes v
      LEFT JOIN candidates c ON c.name = v.first_choice AND c.poll_id = v.poll_id
      WHERE
        v.poll_id = #{self.id} AND
        TRIM(v.first_choice <> '')
      GROUP BY v.first_choice
      ORDER BY votes DESC
    ")
  end

  def total_voters
    self.votes.count
  end

  def total_votes
    self.votes.map{ |v| [v.first_choice, v.second_choice, v.third_choice].reject(&:blank?).uniq.length }.sum
  end
end
