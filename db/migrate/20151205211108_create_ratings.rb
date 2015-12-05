class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :rater_id
      t.integer :ratee_id
      t.references :room, index: true, foreign_key: true
      t.boolean :nsfw
      t.integer :value

      t.timestamps null: false
    end

    add_index :ratings, :rater_id
    add_index :ratings, :ratee_id
  end
end
