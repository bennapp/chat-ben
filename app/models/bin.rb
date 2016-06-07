class Bin < ApplicationRecord
  has_many :posts, through: :post_bins
  has_many :post_bins, -> { order(position: :asc) }

  attr_accessor :posts_attributes

  after_save :set_post_bin_position

  accepts_nested_attributes_for :post_bins

  def posts_attributes=(posts_attributes)
    @post_ids = posts_attributes.map { |post_attribute|
      if post_attribute['title'].present?
        post_attribute.delete('id')
        post = Post.create(post_attribute)
        post.id
      elsif post_attribute["id"].present?
        post_attribute["id"]
      end
    }.compact.map(&:to_s)
    self.post_ids = @post_ids
  end

  def set_post_bin_position
    if @post_ids
      post_bins.each do |post_bin|
        post_bin.update_attribute(:position, @post_ids.index(post_bin.post_id.to_s))
      end
    end
  end
end
