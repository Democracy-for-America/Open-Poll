class AddFacebookImageToPolls < ActiveRecord::Migration
  def self.up
    add_attachment :polls, :facebook_image
  end

  def self.down
    remove_attachment :polls, :facebook_image
  end
end
