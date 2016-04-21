class AddVideoToReactions < ActiveRecord::Migration[5.0]
  def up
    add_attachment :reactions, :video
  end

  def down
    remove_attachment :reactions, :video
  end
end
