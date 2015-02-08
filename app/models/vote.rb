class Vote < ActiveRecord::Base
  belongs_to :poll

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_ZIP_REGEX = /\A\d{5}(-\d{4})?\z/
  VALID_NAME_REGEX = /\S+\s\S+/

  validates_uniqueness_of :email, case_sensitive: false
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

  before_save :set_random_hash

  def array
    [self.first_choice, self.second_choice, self.third_choice]
  end

  def vote_id
    self.id
  end

   # Protect against SQL injection
  def first_choice
    (self['first_choice'] || '').gsub(/[^a-zA-Z]/, '')
  end
  def second_choice
    (self['second_choice'] || '').gsub(/[^a-zA-Z]/, '')
  end
  def third_choice
    (self['third_choice'] || '').gsub(/[^a-zA-Z]/, '')
  end

  def candidates
    Candidate.find_by_sql %Q[
      SELECT c.*,
      CASE REGEXP_REPLACE(c.name, '[^a-zA-Z]', '')
      WHEN '#{self.first_choice}' THEN 'first'
      WHEN '#{self.second_choice}' THEN 'second'
      WHEN '#{self.third_choice}' THEN 'third'
      ELSE NULL
      END AS ranking
      FROM candidates c
      WHERE
      c.poll_id = #{self.poll_id} AND
      c.show_on_ballot = 'true'
      ORDER BY c.name IN ('#{self.first_choice}', '#{self.second_choice}', '#{self.third_choice}') ASC
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

  def share_link(domain)
    "#{domain}/?r=#{self.random_hash}"
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
    candidates = Vote.find_by_sql("SELECT votes.first_choice, COUNT(*) AS total FROM votes GROUP BY votes.first_choice ORDER BY COUNT(*) DESC")
    ( 1 + (candidates.index { |c| c['first_choice'] == self.top_choice } || Candidate.count) ).ordinalize
  end
end