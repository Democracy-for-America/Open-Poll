class VoteMailer < ActionMailer::Base

  default from: '"DFA Pulse Poll Team" <info@democracyforamerica.com>'

  def confirmation(vote, domain, poll_slug)
    @vote = vote
    @domain = domain
    @poll_slug = poll_slug

    mail(
      to: @vote.email,
      subject: "Thanks for your vote"
    )
  end

end
