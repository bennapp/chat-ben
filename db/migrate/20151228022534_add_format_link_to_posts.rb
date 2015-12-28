class AddFormatLinkToPosts < ActiveRecord::Migration
  def change
  	add_column :posts, :format_link, :string
  end
end
