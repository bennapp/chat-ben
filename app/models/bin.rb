class Bin < ApplicationRecord
  has_many :posts, through: :post_bins
  has_many :post_bins, -> { order(position: :asc) }

  attr_accessor :posts_attributes

  after_save :set_post_bin_position
  after_save :set_other_bin_positions
  before_save :set_postition_if_nil

  accepts_nested_attributes_for :post_bins

  def set_postition_if_nil
    self.position = Bin.maximum('position') + 1 if position.nil?
  end

  def set_other_bin_positions
    return unless self.position_changed?
    max_position = Bin.maximum('position')

    other_bins = Bin.where.not(id: self.id).sort_by { |bin| bin.position }.to_a
    other_positions = (0..max_position + 1).to_a - [self.position]

    other_bins.each_with_index do |bin, index|
      new_position = other_positions[index]
      bin.update_column(:position, new_position) unless bin.position == new_position
    end

    true
  end

  def posts_attributes=(posts_attributes)
    @post_ids = posts_attributes.map { |post_attribute|
      if post_attribute['title'].present?
        post_attribute.delete('id')
        post = Post.create(post_attribute.merge({bin_id: id}))
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
