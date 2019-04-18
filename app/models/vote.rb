class Vote < ActiveRecord::Base
  belongs_to :poll

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_ZIP_REGEX = /\A\d{5}(-\d{4})?\z/
  VALID_NAME_REGEX = /\S+\s+\S+/

  # validates :email, uniqueness: { case_sensitive: false, scope: :poll_id }
  validates_format_of :email, {with: VALID_EMAIL_REGEX, message: "is invalid"}
  validates_format_of :name, {with: VALID_NAME_REGEX, message: "required"}
  validates_format_of :zip, {with: VALID_ZIP_REGEX, message: "is invalid"}
  
  validates_length_of :name, maximum: 255
  validates_length_of :email, maximum: 255
  validates_length_of :phone, maximum: 255
  validates_length_of :full_querystring, maximum: 255
  validates_length_of :source, maximum: 255
  validates_length_of :referring_vote_id, maximum: 255
  validates_length_of :first_choice, maximum: 255
  validates_length_of :second_choice, maximum: 255
  validates_length_of :third_choice, maximum: 255

  validate :phone_length

  def phone_length
    unless self.phone.to_s.gsub(/\D/, '').length == 0 || self.phone.to_s.gsub(/\D/, '').length >= 10
      self.errors.add(:phone, "Please enter a ten-digit number")
    end
  end

  before_validation :downcase_email
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
        phone: self.phone,
        action_sms_opt_in: self.sms_opt_in,
        action_provided_mobile_phone: self.phone,
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

  def candidates
    Candidate.find_by_sql("
      SELECT
        c.*
      FROM candidates c
      WHERE
        c.poll_id = #{ self.poll_id } AND
        c.show_on_ballot = 1
    ")
  end

  # Helper methods to pick the top three choices of each vote
  def first_choice_model
    self.candidates.select{ |c| c.name == self.first_choice }[0]
  end

  def second_choice_model
    self.candidates.select{ |c| c.name == self.second_choice }[0]
  end

  def third_choice_model
    self.candidates.select{ |c| c.name == self.third_choice }[0]
  end

  def find_candidate_by_slug(s)
    self.candidates.select{ |c| c.slug == s }[0]
  end

  # Various methods used for generating social media share URLs
  # and other assorted snippets for use in after-action email
  def share_link(domain, poll_slug)
    poll_slug ?
    "#{domain}/#{poll_slug}/s/#{self.hash}" :
    "#{domain}/s/#{self.hash}"
  end

  def twitter_link(domain, poll_slug)
    "https://twitter.com/intent/tweet?url=#{ ERB::Util.url_encode self.share_link(domain, poll_slug) }&text=#{ ERB::Util.url_encode self.poll.twitter_text }"
  end

  def facebook_link(domain, poll_slug)
    "https://www.facebook.com/sharer/sharer.php?u=#{self.share_link(domain, poll_slug)}"
  end

  def change_link(domain, poll_slug)
    poll_slug ?
    "#{domain}/#{poll_slug}/?hash=#{self.hash}" :
    "#{domain}/?hash=#{self.hash}"
  end

  def top_choice
    [self.first_choice, self.second_choice, self.third_choice].reject(&:blank?).first
  end

  def rank
    candidates = Vote.find_by_sql("
      SELECT
        v.first_choice,
        COUNT(DISTINCT v.email) AS total
      FROM votes v
      LEFT JOIN votes w ON v.email = w.email AND v.poll_id = w.poll_id AND w.id > v.id
      WHERE
        w.id IS NULL AND
        v.poll_id = 7
      GROUP BY v.first_choice
      ORDER BY total DESC
    ")

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

  def self.dec_to_b62 int
    encoding = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    return '0' if int == 0

    res = ''
    while int > 0
      d = int % 62
      res << encoding[d]
      int -= d
      int /= 62
    end

    return res.reverse
  end


  def self.b62_to_dec str
    encoding = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    res = 0

    for char in str.chars
      res *= 62
      res += encoding.index(char)
    end

    return res
  end

  def self.encode_hash cleartext
    hash = Digest::SHA256.base64digest(ENV['VOTE_HASH_SECRET'] + '-' + cleartext.to_s).gsub(/[\+\/]/, '+' => '-', '/' => '_').gsub(/=+$/, '').first(6)
    return cleartext.to_s + '-' + hash
  end

  def self.valid_hash? hash
    if hash.blank?
      return false
    else
      cleartext = hash.partition('-').first
      urlsafe_digest = Digest::SHA256.base64digest(ENV['VOTE_HASH_SECRET'] + '-' + cleartext.to_s).gsub(/[\+\/]/, '+' => '-', '/' => '_').gsub(/=+$/, '').first(6)
      return hash.partition('-').last == urlsafe_digest
    end
  end

  def hash
    Vote.encode_hash(Vote.dec_to_b62(self.id))
  end

  def self.find_by_hash hash
    if Vote.valid_hash? hash
      vote_id = Vote.b62_to_dec(hash.split('-')[0])
      return Vote.find vote_id
    else
      return nil
    end
  end
end
