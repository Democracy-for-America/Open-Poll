class AddActionkitPageToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :actionkit_page, :string
  end
end
