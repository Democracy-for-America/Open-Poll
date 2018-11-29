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
    total = Vote.find_by_sql("SELECT COUNT(DISTINCT email) AS total FROM votes WHERE poll_id = #{ self.id } AND first_choice <> ''").try(:first).try(:total) || 0

    candidates = Candidate.find_by_sql("
      SELECT
        c.name AS first_choice,
        c.*,
        100.0 * COUNT(v.id) / #{ total } AS percent
      FROM candidates c
      JOIN votes v ON c.name = v.first_choice AND c.poll_id = v.poll_id
      LEFT JOIN votes w ON v.poll_id = w.poll_id AND v.email = w.email AND v.id < w.id
      WHERE
        w.id IS NULL AND
        c.poll_id = #{ self.id } AND
        v.first_choice = c.name AND
        c.show_in_results = 1
      GROUP BY
        c.id
      ORDER BY COUNT(*) DESC
      LIMIT 5
    ")
  end

  # Used to generate intital bar graph display when results page is loaded,
  # before a user has eliminated any candidates from the running.
  def initial_results t = Time.now.to_s(:db)
    Candidate.find_by_sql("
      SELECT
        c.*,
        CASE
        WHEN c.id THEN c.name
        WHEN v.first_choice = '' AND v.second_choice = '' AND v.third_choice = ''
        THEN 'Blank'
        ELSE 'Other' END as top_choice,
        COUNT(v.id) AS total
      FROM votes v
      LEFT JOIN candidates c ON c.poll_id = v.poll_id AND c.name =
        CASE
        WHEN v.first_choice <> '' THEN v.first_choice
        WHEN v.second_choice <> '' THEN v.second_choice
        WHEN v.third_choice <> '' THEN v.third_choice
        END
      LEFT JOIN votes w ON v.poll_id = w.poll_id AND v.email = w.email AND v.id < w.id AND w.created_at < '#{ t }'
      WHERE
        v.created_at < '#{ t }' AND
        w.id IS NULL AND
        v.poll_id = #{ self.id }
      GROUP BY top_choice
      HAVING top_choice <> 'Blank'
      ORDER BY top_choice = 'Other', total DESC
    ")
  end

  # Used to add votes to runner-ups when candidates are eliminated from the running
  # For Postgres, use:
  #   STRING_AGG(CONCAT(runner_up, ':', gain), ';') AS gains
  # in replace of
  #   GROUP_CONCAT(CONCAT(runner_up, ':', gain) SEPERATOR ';') AS gains
  def runoff_results t = Time.now.to_s(:db)
    hash = []

    Vote.find_by_sql("
      SELECT
        CASE
        WHEN c1.id THEN v.first_choice
        WHEN v.first_choice = '' THEN ''
        ELSE 'OTHER' END AS first_choice,
        CASE
        WHEN c2.id THEN v.second_choice
        WHEN v.second_choice = '' THEN ''
        ELSE 'OTHER' END AS second_choice,
        CASE
        WHEN c3.id THEN v.third_choice
        WHEN v.third_choice = '' THEN ''
        ELSE 'OTHER' END AS third_choice,
        COUNT(*) AS total
      FROM votes v
      LEFT JOIN candidates c1 ON v.first_choice = c1.name AND v.poll_id = c1.poll_id AND c1.show_in_results = 1
      LEFT JOIN candidates c2 ON v.second_choice = c2.name AND v.poll_id = c2.poll_id AND c2.show_in_results = 1
      LEFT JOIN candidates c3 ON v.third_choice = c3.name AND v.poll_id = c3.poll_id AND c3.show_in_results = 1
      LEFT JOIN votes w ON v.poll_id = w.poll_id AND v.email = w.email AND v.id < w.id AND w.created_at < '#{ t }'
      WHERE
        v.created_at < '#{ t }' AND
        w.id IS NULL AND
        v.poll_id = #{ self.id }
      GROUP BY v.first_choice, v.second_choice, v.third_choice
    ").each do |set|
      candidate_array = [set.first_choice.upcase, set.second_choice.upcase, set.third_choice.upcase].reject(&:blank?)
      candidate_array.fill('BLANK', candidate_array.length...3)
      hash << { candidates: candidate_array, total: set.total }
    end

    return hash
  end

  # Intended for internal display
  def raw_results t = Time.now.to_s(:db)
    total = self.votes.count

    Vote.find_by_sql("
      SELECT
        v.first_choice,
        c.id AS candidate_id,
        COUNT(DISTINCT v.email) AS votes,
        COUNT(DISTINCT v.ip_address) AS distinct_ip_addresses,
        COUNT(DISTINCT v.session_cookie) AS distinct_session_cookies,
        SUM(v.verified_auth_token <> 1) AS unverified_auth_tokens,
        (SELECT COUNT(DISTINCT w.email) FROM votes w WHERE v.poll_id = w.poll_id AND (v.first_choice = w.first_choice OR v.first_choice = w.second_choice OR v.first_choice = w.third_choice)) AS all_votes
      FROM votes v
      LEFT JOIN votes w ON v.poll_id = w.poll_id AND v.email = w.email AND v.id < w.id
      LEFT JOIN candidates c ON c.name = v.first_choice AND c.poll_id = v.poll_id
      WHERE
        v.created_at < '#{ t }' AND
        w.id IS NULL AND
        v.poll_id = #{self.id} AND
        TRIM(v.first_choice <> '')
      GROUP BY v.first_choice
      ORDER BY votes DESC
    ")
  end

  def total_voters t = Time.now.to_s(:db)
    self.votes.where("(first_choice <> '' OR second_choice <> '' OR third_choice <>'') AND created_at < '#{ t }'").select(:email).distinct.count
  end

  def total_votes t = Time.now.to_s(:db)
    Vote.find_by_sql("
      SELECT
        *
      FROM votes v
      LEFT JOIN votes w ON v.poll_id = w.poll_id AND v.email = w.email AND v.id < w.id AND w.created_at < '#{ t }'
      WHERE
        v.created_at < '#{ t }' AND
        w.id IS NULL AND
        v.poll_id = #{self.id}
    ").map{ |v| [v.first_choice, v.second_choice, v.third_choice].reject(&:blank?).uniq.length }.sum
  end

  def voting_ended?
    self.voting_ends_at.present? && self.voting_ends_at < Time.now
  end
end
