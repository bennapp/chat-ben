class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.references :room, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
