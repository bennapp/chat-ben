class AddDislikeToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :dislike, :boolean, null: false, default: false
  end
end
