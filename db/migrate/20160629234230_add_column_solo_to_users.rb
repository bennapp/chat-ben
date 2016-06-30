class AddColumnSoloToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :solo, :boolean, default: false, null: false
  end
end
