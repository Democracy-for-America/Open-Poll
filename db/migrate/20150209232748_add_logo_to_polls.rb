class AddLogoToPolls < ActiveRecord::Migration
  def self.up
    add_attachment :polls, :logo
  end

  def self.down
    remove_attachment :polls, :logo
  end
end
