class AddFormatTypeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :format_type, :string
  end
end
