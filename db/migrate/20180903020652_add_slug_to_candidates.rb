class AddSlugToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :slug, :string, index: true
  end
end
