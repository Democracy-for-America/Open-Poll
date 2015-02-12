class CacheRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll)
    Rails.cache.write("results/intital/#{poll.id}", poll.initial_results)
    Rails.cache.write("results/runoff/#{poll.id}", poll.runoff_results)
  end
end
