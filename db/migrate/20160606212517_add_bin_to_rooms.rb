class AddBinToRooms < ActiveRecord::Migration[5.0]
  def change
    add_reference :rooms, :bin, foreign_key: true
  end
end
