class DropTableStats < ActiveRecord::Migration[5.0]
  def change
    drop_table :stats
  end
end
