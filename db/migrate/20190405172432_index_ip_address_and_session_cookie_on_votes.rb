class IndexIpAddressAndSessionCookieOnVotes < ActiveRecord::Migration
  def change
    add_index :votes, :ip_address
    add_index :votes, :session_cookie
  end
end
