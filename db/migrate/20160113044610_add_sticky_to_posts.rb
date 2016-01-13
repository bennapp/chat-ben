class AddStickyToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :sticky, :boolean
  end
end
