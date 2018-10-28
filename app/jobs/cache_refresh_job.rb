class CacheRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll)
    timestamp = (Time.now - 1.minute).to_s(:db)
    initial_results = poll.initial_results(timestamp)

    Rails.cache.write("results/timestamp/#{poll.id}", timestamp)
    Rails.cache.write("results/initial_results/#{poll.id}", initial_results)
    Rails.cache.write("results/runoff_results/#{poll.id}", poll.runoff_results(timestamp))
    Rails.cache.write("results/max_votes/#{poll.id}", initial_results[0].total)
    Rails.cache.write("results/total_voters/#{poll.id}", poll.total_voters(timestamp))
  end
end
