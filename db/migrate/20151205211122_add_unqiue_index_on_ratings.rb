class AddUnqiueIndexOnRatings < ActiveRecord::Migration
  def change
    add_index :ratings, [:room_id, :rater_id, :ratee_id], :unique => true
  end
end
