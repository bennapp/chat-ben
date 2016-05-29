class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:home]

  def home
    @post = Post.new
    @bins = Bin.all
  end
end
