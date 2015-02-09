class AddResultsTextToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :results_text, :text
  end
end
