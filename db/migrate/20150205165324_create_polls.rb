class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :title
      t.string :subtitle
      t.string :short_name
      t.boolean :end_voting
      t.boolean :show_results

      t.timestamps null: false
    end
  end
end
