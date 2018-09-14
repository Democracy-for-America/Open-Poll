class AddFromLineToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :from_line, :string
  end
end
