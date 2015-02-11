class RenameEmailClosuretoEmailTemplate < ActiveRecord::Migration
  def change
    change_table :polls do |t|
      t.rename :email_closure, :email_template
    end
  end
end
