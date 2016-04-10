class AddFreshToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :fresh, :boolean, null: false, default: false
  end
end
