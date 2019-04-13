class CacheAfterActionResultsRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll)
    timestamp = (Time.now - 1.minute).to_s(:db)
    results = poll.results(timestamp)

    Rails.cache.write("results/after_action_timestamp/#{poll.id}", timestamp)
    Rails.cache.write("results/after_action/#{poll.id}", results)
  end
end
