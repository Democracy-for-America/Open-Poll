class AddInstrunctionsToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :instructions, :string
  end
end
