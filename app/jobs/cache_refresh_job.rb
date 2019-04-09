class CacheRefreshJob < ActiveJob::Base
  queue_as :default

  def perform(poll, json)
    opts = JSON(json).symbolize_keys
    timestamp = (Time.now - 1.minute).to_s(:db)
    initial_results = poll.initial_results(timestamp, opts)

    Rails.cache.write("results/timestamp/#{poll.id}?voters=#{ opts[:voters] }&state=#{ opts[:state] }", timestamp)
    Rails.cache.write("results/initial_results/#{poll.id}?voters=#{ opts[:voters] }&state=#{ opts[:state] }", initial_results)
    Rails.cache.write("results/runoff_results/#{poll.id}?voters=#{ opts[:voters] }&state=#{ opts[:state] }", poll.runoff_results(timestamp, opts))
    Rails.cache.write("results/max_votes/#{poll.id}?voters=#{ opts[:voters] }&state=#{ opts[:state] }", initial_results[0].total)
    Rails.cache.write("results/total_voters/#{poll.id}?voters=#{ opts[:voters] }&state=#{ opts[:state] }", poll.total_voters(timestamp, opts))
  end
end
