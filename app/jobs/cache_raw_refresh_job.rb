class CacheRawRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll)
    Rails.cache.write("raw/total_voters/#{poll.id}", poll.total_voters)
    Rails.cache.write("raw/total_votes/#{poll.id}", poll.total_votes)
    Rails.cache.write("raw/results/#{poll.id}", poll.raw_results)
    Rails.cache.write("raw/timestamp/#{poll.id}", Time.now)
  end
end
