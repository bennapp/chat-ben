class CreateStats < ActiveRecord::Migration[5.0]
  def change
    create_table :stats do |t|
      t.string :title
      t.integer :value

      t.timestamps
    end
  end
end
