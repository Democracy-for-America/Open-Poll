class AddIndexOnEmailToVotes < ActiveRecord::Migration
  def change
    add_index :votes, :email
  end
end
