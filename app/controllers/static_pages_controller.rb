class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:home]

  def home
    @post = Post.new
    @bins = Bin.without_deleted.includes(:posts).order('post_bins.position asc').order(:position)
  end
end
