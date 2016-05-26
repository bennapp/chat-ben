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
    @bin = Bin.new(title: bin_params["title"])
    @bin.post_ids = bin_params["post_ids"].values

    if @bin.save
      redirect_to @bin, notice: 'Bin was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /bins/1
  def update
    if @bin.update(title: bin_params["title"], post_ids: bin_params["post_ids"].values)
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
    params.require(:bin).permit(:title, :post_ids => (0..19).to_a.map(&:to_s) )
  end

  def redirect_if_non_admin
    redirect_to rooth_path unless current_user.is_admin?
  end
end
