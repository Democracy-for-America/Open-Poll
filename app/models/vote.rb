class Vote < ActiveRecord::Base
  belongs_to :poll

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_ZIP_REGEX = /\A\d{5}(-\d{4})?\z/
  VALID_NAME_REGEX = /\S+\s\S+/

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

  def find_candidate_by_name(name)
    self.candidates.select{ |c| c.name == name }[0]
  end

  def unranked_candidates
    self.candidates.select{ |c| c.ranking.nil? }
  end

  def set_random_hash
    self.random_hash ||= SecureRandom.urlsafe_base64(16)
  end

  def parent(hash)
    hash ? Vote.find_by_random_hash(hash) : nil
  end

  # Various methods used for generating social media share URLs
  # and other assorted snippets for use in after-action email
  def share_link(domain)
    "#{domain}/#{self.poll.short_name}/?r=#{self.random_hash}"
  end

  def twitter_text
    "Find out who I voted for in Democracy for America's #{self.poll.name}, and submit your top picks!"
  end

  def twitter_link(domain)
    "https://twitter.com/intent/tweet?url=#{ CGI.escape self.share_link(domain) }&text=#{ CGI.escape self.twitter_text }"
  end

  def facebook_link(domain)
    "https://www.facebook.com/sharer/sharer.php?u=#{self.share_link(domain)}"
  end

  def change_link(domain)
    "#{domain}/votes/new?hash=#{self.random_hash}"
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
  def thank_you_email(domain)
    self
      .poll
      .email_template
      .gsub('{{ first_name }}', self.name.split.first)
      .gsub('{{ share_url }}', self.share_link(domain))
      .gsub('{{ twitter_url }}', self.twitter_link(domain))
      .gsub('{{ facebook_url }}', self.facebook_link(domain))
      .gsub('{{ change_url }}', self.change_link(domain))
      .gsub('{{ top_candidate }}', self.top_choice)
      .gsub('{{ rank }}', self.rank)
      .gsub('{{ keep_or_put }}', self.rank == '1st' ? 'keep' : 'put')
  end
end
