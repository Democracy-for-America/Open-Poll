class AddPhoneToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :phone, :string
    add_column :votes, :sms_opt_in, :boolean
  end
end
