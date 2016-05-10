class PostBin < ActiveRecord::Base
  belongs_to :post
  belongs_to :bin, autosave: true
end
