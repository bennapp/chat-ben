class AddWaitingToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :waiting, :boolean, null: false, default: false
  end
end
