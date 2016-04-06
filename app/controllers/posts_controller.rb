class PostsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index]
  before_action :set_post, only: [:show]
  before_action :set_current_users_post, only: [:edit, :update, :destroy]

  def index
    @post = Post.new
    @posts = Post.without_deleted.from_three_weeks_ago.includes(:rooms).includes(:likes)
    @posts = @posts.sort_by { |post|
      if post.num_waiting > 0
        -2**16
      elsif post.sticky?
        -2**8
      else
        -post.likes.count
      end
    }
  end

  def show
    room = @post.rooms.where('rooms.full is false').where('rooms.waiting is true').first
    if !room.present? || rated_waiting_users_poorly?(room.participations.pluck(:user_id))
      room = @post.rooms.create
    end

    redirect_to room_path(room)
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.sticky = false unless current_user.is_ben?

    respond_to do |format|
      if @post.save
        room = @post.rooms.create
        format.html { redirect_to room_path(room), notice: 'Post was successfully created.' }
      else
        format.html { redirect_to root_path, alert: @post.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to posts_path, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    render nothing: true
  end

  private

  def set_current_users_post
    @post = current_user.posts.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :link, :text_content, :sticky)
  end

  def rated_waiting_users_poorly?(user_ids)
    Rating.where(rater: current_user).where('ratee_id in (?)', user_ids).where('value <= 2').any? || Rating.where(ratee: current_user).where('rater_id in (?)', user_ids).where('value <= 2').any?
  end
end
