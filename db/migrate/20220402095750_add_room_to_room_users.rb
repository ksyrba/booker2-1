class AddRoomToRoomUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :room_users, :room, null: false, foreign_key: true
  end
end
