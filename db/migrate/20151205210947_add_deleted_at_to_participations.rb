class AddDeletedAtToParticipations < ActiveRecord::Migration
  def change
    add_column :participations, :deleted_at, :datetime
    add_index :participations, :deleted_at
  end
end
