class VoteMailer < ActionMailer::Base

  default from: '"DFA Pulse Poll Team" <info@democracyforamerica.com>'

  def confirmation(vote, domain, poll_slug)
    @vote = vote
    @domain = domain
    @poll_slug = poll_slug

    mail(
      from: @vote.poll.from_line,
      to: @vote.email,
      subject: "Thanks! Now share your vote for #{ @vote.top_choice }"
    )
  end

end
