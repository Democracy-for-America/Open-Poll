class AddNameAndEmailClosureToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :name, :string
    add_column :polls, :email_closure, :text
  end
end
