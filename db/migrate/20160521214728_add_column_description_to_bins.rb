class AddColumnDescriptionToBins < ActiveRecord::Migration[5.0]
  def change
    add_column :bins, :description, :string
  end
end
