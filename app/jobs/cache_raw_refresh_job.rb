class CacheRawRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll)
    Rails.cache.write("raw/total/#{poll.id}", poll.votes.count)
    Rails.cache.write("raw/results/#{poll.id}", poll.raw_results)
    Rails.cache.write("raw/timestamp/#{poll.id}", Time.now)
  end
end
