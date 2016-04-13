class AddCommentToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :comment, :string
  end
end
