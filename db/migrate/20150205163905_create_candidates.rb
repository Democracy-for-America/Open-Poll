class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :office
      t.boolean :show_on_ballot
      t.boolean :show_in_results

      t.timestamps null: false
    end
  end
end
