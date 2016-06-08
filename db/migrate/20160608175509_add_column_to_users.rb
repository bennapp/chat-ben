class AddColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :matching, :boolean, default: true
  end
end
