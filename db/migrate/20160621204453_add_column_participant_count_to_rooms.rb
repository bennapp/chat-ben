class AddColumnParticipantCountToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :participant_count, :integer, default: 0
  end
end
