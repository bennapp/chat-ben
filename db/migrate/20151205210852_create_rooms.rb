class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :post, index: true, foreign_key: true, null: true
      t.string :token

      t.timestamps null: false
    end
  end
end
