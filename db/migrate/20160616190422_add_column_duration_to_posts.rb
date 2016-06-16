class AddColumnDurationToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :duration, :integer
  end
end
