class AddCustomCssToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :custom_css, :text
  end
end
