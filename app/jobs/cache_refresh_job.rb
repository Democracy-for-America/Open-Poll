class CacheRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll)
    Rails.cache.write("results/initial/#{poll.id}", poll.initial_results)
    Rails.cache.write("results/runoff/#{poll.id}", poll.runoff_results)
    Rails.cache.write("results/timestamp/#{poll.id}", Time.now)
  end
end
