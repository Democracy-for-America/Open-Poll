class AddDonationUrlToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :donation_url, :string
  end
end
