class AddSocialMediaFieldsToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :twitter_text, :string
    add_column :polls, :vote_page_og_title, :string
    add_column :polls, :results_page_og_title, :string
    add_column :polls, :vote_page_og_description, :string, limit: 300
    add_column :polls, :results_page_og_description, :string, limit: 300
  end
end
