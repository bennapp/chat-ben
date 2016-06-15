class AddPositionToBins < ActiveRecord::Migration[5.0]
  def up
    add_column :bins, :position, :integer

    next_position = 0
    Bin.where(position: nil).sort_by { |bin| bin.id }.each_with_index do |bin, index|
      bin.update_attribute(:position, next_position + index)
    end
  end

  def down
    remove_column :bins, :position
  end
end
