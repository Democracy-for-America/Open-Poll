class AddNonvalidToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :nonvalid, :boolean, null: false, default: false
    add_index :votes, :nonvalid
  end
end
