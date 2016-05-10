class Bin < ApplicationRecord
  has_many :posts, through: :post_bins
  has_many :post_bins, -> { order(position: :asc) }

  after_save :set_post_bin_position

  def post_ids=(post_ids)
    post_bins.delete_all
    super(post_ids)
    @post_ids = post_ids.reject { |post_id| post_id.empty? }
  end

  def set_post_bin_position
    if @post_ids
      post_bins.each do |post_bin|
        post_bin.update_attribute(:position, @post_ids.index(post_bin.post_id.to_s))
      end
    end
  end
end
