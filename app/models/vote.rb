class Vote < ActiveRecord::Base
  belongs_to :poll

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_ZIP_REGEX = /\A\d{5}(-\d{4})?\z/
  VALID_NAME_REGEX = /\S+\s+\S+/

  validates :email, uniqueness: { case_sensitive: false, scope: :poll_id }
  validates_format_of :email, {with: VALID_EMAIL_REGEX, message: "is invalid"}
  validates_format_of :name, {with: VALID_NAME_REGEX, message: "required"}
  validates_format_of :zip, {with: VALID_ZIP_REGEX, message: "is invalid"}
  
  validates_length_of :name, maximum: 255
  validates_length_of :email, maximum: 255
  validates_length_of :full_querystring, maximum: 255
  validates_length_of :source, maximum: 255
  validates_length_of :referring_vote_id, maximum: 255
  validates_length_of :first_choice, maximum: 255
  validates_length_of :second_choice, maximum: 255
  validates_length_of :third_choice, maximum: 255

  before_validation :downcase_email
  before_save :set_random_hash
  after_save :build_actionkit_sync_job

  def build_actionkit_sync_job
    ActionkitSyncJob.perform_later(self) unless self.poll.actionkit_page.blank?
  end

  # Sync to ActionKit if ActionKit API connection is configured
  def sync_to_actionkit
    unless self.poll.actionkit_page.blank?
      body = {
        page: self.poll.actionkit_page,
        name: self.name,
        email: self.email,
        zip: self.zip,
        action_first_choice: self.first_choice,
        action_second_choice: self.second_choice,
        action_third_choice: self.third_choice,
        action_vote_id: self.vote_id,
        action_referring_vote_id: self.vote_id,
        referring_akid: self.referring_akid,
        source: self.source
      }

      result = HTTParty.get("https://#{ ENV['ACTIONKIT_DOMAIN'] }/act?#{ body.to_query }")
      action_id = CGI::parse(result.request.last_uri.to_s.split('?')[1])['action_id'][0]
      self.update_column(:actionkit_id, action_id) if action_id
    end
  end

  def downcase_email
    self.email = self.email.downcase
  end

  def array
    [self.first_choice, self.second_choice, self.third_choice]
  end

  def vote_id
    self.id
  end

  # Protect against SQL injection
  # For Postgres use:
  #   gsub(/[^a-zA-Z]/, '')
  # instead of:
  #   gsub('\'', '')
  def first_choice
    (self['first_choice'] || '').gsub('\'', '')
  end
  def second_choice
    (self['second_choice'] || '').gsub('\'', '')
  end
  def third_choice
    (self['third_choice'] || '').gsub('\'', '')
  end

  # For Postgres use:
  #   CASE REGEXP_REPLACE(c.name, '[^a-zA-Z]', '', 'g')
  # instead of:
  #   REPLACE(c.name, '''', '')
  def candidates
    Candidate.find_by_sql %Q[
      SELECT
        c.*,
        CASE REPLACE(c.name, '''', '')
        WHEN '#{self.first_choice}' THEN 'first'
        WHEN '#{self.second_choice}' THEN 'second'
        WHEN '#{self.third_choice}' THEN 'third'
        ELSE NULL
      END AS ranking
      FROM candidates c
      WHERE
      c.poll_id = #{self.poll_id} AND
      c.show_on_ballot = 1
      ORDER BY REPLACE(c.name, '''', '') IN ('#{self.first_choice}', '#{self.second_choice}', '#{self.third_choice}') ASC
    ]
  end

  # Helper methods to pick the top three choices of each vote
  def first_choice_model
    self.candidates.select{ |c| c.ranking == 'first' }[0]
  end
  def second_choice_model
    self.candidates.select{ |c| c.ranking == 'second' }[0]
  end
  def third_choice_model
    self.candidates.select{ |c| c.ranking == 'third' }[0]
  end

  def find_candidate_by_name(n)
    self.candidates.select{ |c| c.name == n }[0]
  end

  def find_candidate_by_slug(s)
    self.candidates.select{ |c| c.slug == s }[0]
  end

  def unranked_candidates
    self.candidates.select{ |c| c.ranking.nil? }
  end

  # Create a random-looking string to ID votes for the purpose of referral tracking, etc.
  # Use the current Unix timestamp to decrease the odds of a collision
  def set_random_hash
    self.random_hash ||= Time.now.to_i.to_s.reverse.split('').zip(SecureRandom.urlsafe_base64(12).split('')).flatten.compact.join
  end

  def parent(hash)
    hash ? Vote.find_by_random_hash(hash) : nil
  end

  # Various methods used for generating social media share URLs
  # and other assorted snippets for use in after-action email
  def share_link(domain, poll_slug)
    poll_slug ?
    "#{domain}/#{poll_slug}/s/#{self.random_hash}" :
    "#{domain}/s/#{self.random_hash}"
  end

  def twitter_link(domain, poll_slug)
    "https://twitter.com/intent/tweet?url=#{ ERB::Util.url_encode self.share_link(domain, poll_slug) }&text=#{ ERB::Util.url_encode self.poll.twitter_text }"
  end

  def facebook_link(domain, poll_slug)
    "https://www.facebook.com/sharer/sharer.php?u=#{self.share_link(domain, poll_slug)}"
  end

  def change_link(domain, poll_slug)
    poll_slug ?
    "#{domain}/#{poll_slug}/?hash=#{self.random_hash}" :
    "#{domain}/?hash=#{self.random_hash}"
  end

  def top_choice
    if self.first_choice == '' && self.second_choice == ''
      return self['third_choice']
    elsif self.first_choice == ''
      return self['second_choice']
    else
      return self['first_choice']
    end
  end

  def rank
    candidates = Vote.select('votes.first_choice, COUNT(*) AS total').where(poll_id: self.poll_id).group(:first_choice).order('COUNT(*) DESC')
    ( 1 + (candidates.index { |c| c['first_choice'] == self.top_choice } || Candidate.count) ).ordinalize
  end

  # Allow for a set of white-listed instance methods to be accessed in the context of the after-action email, via {{ snippet }} tags.
  def thank_you_email(domain, poll_slug)
    liquid_binding = {
      'first_name' => self.name.split.first,
      'share_url' => self.share_link(domain, poll_slug),
      'twitter_url' => self.twitter_link(domain, poll_slug),
      'facebook_url' => self.facebook_link(domain, poll_slug),
      'change_url' => self.change_link(domain, poll_slug),
      'top_candidate' => self.top_choice,
      'rank' => self.rank,
      'keep_or_put' => self.rank == '1st' ? 'keep' : 'put'
    }
    template = Liquid::Template.parse self.poll.email_template
    template.render liquid_binding
  end
end
