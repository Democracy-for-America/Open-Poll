class VoteMailer < ActionMailer::Base

  default from: '"DFA Pulse Poll Team" <info@democracyforamerica.com>'

  def confirmation(vote, domain)
    @vote = vote
    @domain = domain

    mail(
      to: @vote.email,
      subject: "Thanks for your vote"
    )
  end

end
