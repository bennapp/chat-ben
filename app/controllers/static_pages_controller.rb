class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:home]

  def home
    @post = Post.new
    @bins = Bin.without_deleted.sort_by { |bin| bin.position }
  end
end
