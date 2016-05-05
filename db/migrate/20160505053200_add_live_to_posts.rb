class AddLiveToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :live, :boolean, null: false, default: false
  end
end
