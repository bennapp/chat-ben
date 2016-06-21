class AddColumnHasRedditCommentToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :has_reddit_comment, :boolean
  end
end
