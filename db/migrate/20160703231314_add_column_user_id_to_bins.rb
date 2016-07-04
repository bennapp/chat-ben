class AddColumnUserIdToBins < ActiveRecord::Migration[5.0]
  def change
    add_reference :bins, :user, foreign_key: true
  end
end
