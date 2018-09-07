class AddHelpTextToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :help_text, :text, limit: 2000
  end
end
