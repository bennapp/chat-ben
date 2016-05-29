class PostsController < ApplicationController
  before_action :set_post, only: [:show]
  before_action :set_current_users_post, only: [:edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    bin_id = post_params[:bin_id]
    @post = Post.new(post_params.except(:bin_id))
    @post.user = current_user
    @post.sticky = false unless current_user.is_admin?
    @post.live = false unless current_user.is_admin?

    respond_to do |format|
      if @post.save && PostBin.create(post_id: @post.id, bin_id: bin_id)
        room = @post.rooms.create
        format.html { redirect_to room_path(room), notice: 'Post was successfully created.' }
        format.json { render json: @post }
      else
        format.html { redirect_to root_path, alert: @post.errors.full_messages.to_sentence }
        format.json { render json: @post.errors, status: :unprocessable_entity }
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
    if current_user.is_admin?
      @post = Post.find(params[:id])
    else
      @post = current_user.posts.find(params[:id])
    end
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :link, :text_content, :sticky, :live, :bin_id)
  end

  def bad_rating?(user_id)
    false
    #return true if current_user.ratings.where('ratee_id = ?', user_id).where('value <= 2').any?
    #return true if current_user.rateeds.where('rater_id = ?', user_id).where('value <= 2').any?
  end

  def just_chat?(user_id)
    (current_user.participations.pluck(:room_id).last(3) & User.find(user_id).participations.pluck(:room_id).last(3)).present?
  end
end
