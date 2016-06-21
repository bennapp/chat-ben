class AddColumnDeletedAtToBins < ActiveRecord::Migration[5.0]
  def change
    add_column :bins, :deleted_at, :datetime
    add_index :bins, :deleted_at
  end
end
