class AddImageToCandidates < ActiveRecord::Migration
  def self.up
    add_attachment :candidates, :image
  end

  def self.down
    remove_attachment :candidates, :image
  end
end
