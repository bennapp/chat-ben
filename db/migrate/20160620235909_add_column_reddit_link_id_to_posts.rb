class AddColumnRedditLinkIdToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :reddit_link_id, :string
  end
end
