class AddAuthenticationTokenToVote < ActiveRecord::Migration
  def change
    add_column :votes, :auth_token, :string
    add_column :votes, :verified_auth_token, :boolean
  end
end
