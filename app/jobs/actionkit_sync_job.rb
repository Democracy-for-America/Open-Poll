class ActionkitSyncJob < ActiveJob::Base
  queue_as :default

  def perform(vote)
    vote.sync_to_actionkit
  end
end
