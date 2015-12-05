class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:destroy]

  def destroy
    @particpation.destroy
    render nothing: true
  end

  private

  def set_participation
    @particpation = current_user.participations.find(params[:id])
  end
end
