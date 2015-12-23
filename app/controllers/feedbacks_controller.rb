class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
    @is_feeback_new = true
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user

    respond_to do |format|
      if @feedback.save
        format.html { redirect_to root_path, notice: 'Feedback was successfully created.' }
        format.json { render :show, status: :created, location: @feedback }
      else
        format.html { render :new }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feedback_params
      params.require(:feedback).permit(:message)
    end
end
