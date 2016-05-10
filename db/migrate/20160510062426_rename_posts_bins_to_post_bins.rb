class RenamePostsBinsToPostBins < ActiveRecord::Migration[5.0]
  def change
    rename_table :posts_bins, :post_bins
  end
end
