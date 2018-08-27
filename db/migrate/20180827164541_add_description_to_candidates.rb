class AddDescriptionToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :description, :text
  end
end
