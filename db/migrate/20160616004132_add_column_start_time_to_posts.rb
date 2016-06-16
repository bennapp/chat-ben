class AddColumnStartTimeToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :start_time, :integer
  end
end
