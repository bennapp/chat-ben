class AddActiveToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :active, :boolean
  end
end
