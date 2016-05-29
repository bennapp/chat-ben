class BinsController < ApplicationController
  before_action :set_bin, only: [:show, :edit, :update, :destroy]
  before_action :redirect_if_non_admin

  # GET /bins
  def index
    @bins = Bin.all
  end

  # GET /bins/1
  def show
  end

  # GET /bins/new
  def new
    @bin = Bin.new
    @posts = Post.without_deleted.from_three_weeks_ago.sort_by { |post| post.title }
  end

  # GET /bins/1/edit
  def edit
    @posts = Post.without_deleted.from_three_weeks_ago.sort_by { |post| post.title }
  end

  # POST /bins
  def create
    @bin = Bin.new(bin_params)

    if @bin.save
      redirect_to @bin, notice: 'Bin was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /bins/1
  def update
    if @bin.update(bin_params)
      redirect_to @bin, notice: 'Bin was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /bins/1
  def destroy
    @bin.destroy
    redirect_to bins_url, notice: 'Bin was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bin
    @bin = Bin.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def bin_params
    @params ||= begin
      request_params = params.require(:bin).permit(:title, :description, :post_ids => (0..19).to_a.map(&:to_s) )
      request_params['post_ids'] = request_params['post_ids'].values
      request_params
    end
  end

  def redirect_if_non_admin
    redirect_to rooth_path unless current_user.is_admin?
  end
end
