class ReactionsController < ApplicationController
  def index
    redirect_to root_path unless current_user.is_admin?
    @reactions = Reaction.all
  end

  def create
    @reaction = Reaction.new
    @reaction.post_id = params['post_id']
    @reaction.user = current_user

    @reaction.video = Paperclip.io_adapters.for(params['video'])
    @reaction.video.instance_write :file_name, "reaction_" + (Reaction.last.id + 1).to_s

    if @reaction.save
      render json: @reaction, status: :created
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  def reaction_params
    params.require(:reaction).permit(:post_id, :video)
  end
end
