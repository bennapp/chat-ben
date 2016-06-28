class BinsController < ApplicationController
  before_action :set_bin, only: [:show, :edit, :update, :destroy]
  before_action :set_post, only: [:show]
  before_action :redirect_if_non_admin, only: [:index, :emails, :new, :edit, :create, :update, :destroy]

  skip_before_filter :authenticate_user!, only: [:show]

  # GET /bins
  def index
    @hide_footer = true
    @bins = Bin.without_deleted.includes(:posts).sort_by { |bin| bin.position }
  end

  # GET /bins/1
  def show
    if not_matching? || browser.device.mobile?
      room = @post.rooms.create(bin: @bin)
    else
      if params['post'].present?
        rooms = @post.rooms.where('rooms.full is false').where('rooms.waiting is true')
        room = rooms.first
      else
        rooms = Room.where('rooms.full is false').where('rooms.waiting is true')
        room = rooms.first
      end

      room = @post.rooms.create(bin: @bin) if room.blank?
    end

    redirect_to room_path(room)
  end

  # GET /bins/new
  def new
    @hide_footer = true
    @bin = Bin.new
    @posts = Post.without_deleted.where(bin_id: @bin.id).order(:title)
  end

  # GET /bins/1/edit
  def edit
    @hide_footer = true
    @posts = Post.without_deleted.where(bin_id: @bin.id).order(:title)
  end

  # POST /bins
  def create
    @bin = Bin.new(bin_params)

    if @bin.save
      redirect_to action: :index, notice: 'Bin was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /bins/1
  def update
    if @bin.update(bin_params)
      redirect_to action: :index, notice: 'Bin was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /bins/1
  def destroy
    @bin.destroy
    redirect_to bins_url, notice: 'Bin was successfully destroyed.'
  end

  def emails
    @users = User.all.sort_by { |user| user.created_at }
    render :emails
  end

  private

  def not_matching?
    current_user && !current_user.matching?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_bin
    @bin = Bin.find(params[:id])
  end

  def set_post
    if params['post'].present?
      @post = @bin.posts.where(id: params['post']).first

      if @post.nil?
        @post = Post.where(id: params['post']).first
        @bin.posts << @post unless @post.nil?
      end
    end

    @post = @bin.posts.first if @post.nil?
  end

  # Only allow a trusted parameter "white list" through.
  def bin_params
    @params ||= begin
      request_params = params.require(:bin).permit(:title, :abbreviation, :description, :position, :logo, :post_ids => (0..50).to_a.map(&:to_s), :posts => [:title, :link, :duration, :text_content] )
      post_ids = request_params['post_ids'].values
      request_params.delete('post_ids')
      posts = request_params['posts'].values
      request_params.delete('posts')

      posts.each_with_index { |post, index| post['id'] = post_ids[index] }
      request_params['posts_attributes'] = posts
      request_params
    end
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
