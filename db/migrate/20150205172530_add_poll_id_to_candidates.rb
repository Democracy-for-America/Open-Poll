class AddPollIdToCandidates < ActiveRecord::Migration
  def change
    add_reference :candidates, :poll, index: true
  end
end
