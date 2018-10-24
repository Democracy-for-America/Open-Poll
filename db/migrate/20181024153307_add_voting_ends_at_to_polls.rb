class AddVotingEndsAtToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :voting_ends_at, :datetime
  end
end
