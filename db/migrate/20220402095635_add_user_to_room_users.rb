class AddUserToRoomUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :room_users, :users, null: false, foreign_key: true
  end
end
