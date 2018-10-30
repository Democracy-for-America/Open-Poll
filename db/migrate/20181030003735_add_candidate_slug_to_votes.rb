class AddCandidateSlugToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :candidate_slug, :string
  end
end
