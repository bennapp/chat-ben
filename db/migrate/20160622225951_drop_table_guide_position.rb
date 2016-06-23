class DropTableGuidePosition < ActiveRecord::Migration[5.0]
  def up
    drop_table :guide_positions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
