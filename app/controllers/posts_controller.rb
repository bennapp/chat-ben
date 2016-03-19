class PostsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index]
  before_action :set_post, only: [:show]
  before_action :set_current_users_post, only: [:edit, :update, :destroy]

  def index
    @post = Post.new
    @posts = Post.without_deleted
  end

  def show
    room = @post.rooms.joins(:participations).group('rooms.id').having('COUNT(participations.id) < 2').first
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
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
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
