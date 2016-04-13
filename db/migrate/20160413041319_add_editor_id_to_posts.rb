class AddEditorIdToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :editor_id, :integer
  end
end
