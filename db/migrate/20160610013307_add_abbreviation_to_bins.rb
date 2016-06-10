class AddAbbreviationToBins < ActiveRecord::Migration[5.0]
  def change
    add_column :bins, :abbreviation, :string
  end
end
