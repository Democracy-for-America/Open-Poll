class AddPollIdToVotes < ActiveRecord::Migration
  def change
    add_reference :votes, :poll, index: true
  end
end
