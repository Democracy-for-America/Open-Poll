class AddFacebookFieldsToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :share_vote_og_title, :string
    add_column :polls, :share_vote_og_description, :string, limit: 300
    add_column :polls, :promote_candidate_og_title, :string
    add_column :polls, :promote_candidate_og_description, :string, limit: 300
  end
end
