class IndexColumnsOnCandidatesAndVotes < ActiveRecord::Migration
  def change
    add_index :candidates, :name
    add_index :votes, :first_choice
    add_index :votes, :second_choice
    add_index :votes, :third_choice
  end
end
