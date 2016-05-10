class CreateBins < ActiveRecord::Migration[5.0]
  def change
    create_table :bins do |t|
      t.string :title

      t.timestamps
    end
  end
end
