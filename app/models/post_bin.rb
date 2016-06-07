class PostBin < ActiveRecord::Base
  belongs_to :post
  belongs_to :bin, autosave: true

  accepts_nested_attributes_for :bin
end
