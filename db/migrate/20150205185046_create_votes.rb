class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.string :email
      t.string :name
      t.string :zip
      t.string :first_choice
      t.string :second_choice
      t.string :third_choice
      t.string :source
      t.integer :actionkit_id
      t.string :random_hash
      t.string :ip_address
      t.string :session_cookie
      t.text :full_querystring
      t.integer :referring_vote_id
      t.string :referring_akid

      t.timestamps null: false
    end
  end
end
