class PostBin < ActiveRecord::Base
  belongs_to :post
  belongs_to :bin, autosave: true
  validates :post_id, uniqueness: { scope: :bin_id }
end