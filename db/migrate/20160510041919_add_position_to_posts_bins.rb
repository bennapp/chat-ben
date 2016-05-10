class AddPositionToPostsBins < ActiveRecord::Migration[5.0]
  def change
    add_column :posts_bins, :position, :integer
  end
end
