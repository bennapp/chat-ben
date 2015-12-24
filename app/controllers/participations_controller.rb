class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:destroy]

  def destroy
    @particpation.try(:destroy)
    render nothing: true
  end

  private

  def set_participation
    @particpation = current_user.participations.where(id: params[:id]).first
  end
end
