class ReactionsController < ApplicationController
  def create
    @reaction = Reaction.new
    @reaction.post_id = params['post_id']
    @reaction.user = current_user

    @reaction.video = Paperclip.io_adapters.for(params['video'])
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
