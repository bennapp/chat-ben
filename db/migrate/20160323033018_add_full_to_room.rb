class AddFullToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :full, :boolean, null: false, default: false
  end
end
