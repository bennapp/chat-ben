class CreateGuidePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :guide_positions do |t|
      t.references :user, foreign_key: true
      t.references :bin, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
