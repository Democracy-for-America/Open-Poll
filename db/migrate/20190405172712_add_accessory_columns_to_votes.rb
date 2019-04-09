class AddAccessoryColumnsToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :state, :string, index: true
    add_column :votes, :ntl, :boolean, index: true
  end
end
