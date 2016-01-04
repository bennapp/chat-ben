class AddTextContentToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :text_content, :text
  end
end
