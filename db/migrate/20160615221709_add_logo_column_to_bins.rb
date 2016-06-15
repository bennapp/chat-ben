class AddLogoColumnToBins < ActiveRecord::Migration[5.0]
  def up
    add_attachment :bins, :logo
  end

  def down
    remove_attachment :bins, :logo
  end
end
