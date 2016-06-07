class AddBinIdToPosts < ActiveRecord::Migration[5.0]
  def change
    add_reference :posts, :bin, foreign_key: true
  end
end
