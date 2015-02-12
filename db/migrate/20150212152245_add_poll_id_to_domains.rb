class AddPollIdToDomains < ActiveRecord::Migration
  def change
    add_reference :domains, :poll, index: true
  end
end
