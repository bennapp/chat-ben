class CreatePostsBins < ActiveRecord::Migration[5.0]
  def change
    create_table :posts_bins do |t|
      t.references :post
      t.references :bin
    end

    add_index :posts_bins, [:post_id, :bin_id]
  end
end
