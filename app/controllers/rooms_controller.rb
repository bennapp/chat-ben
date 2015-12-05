class RoomsController < ApplicationController
  before_action :set_room, only: [:show]

  def show
    participation = Participation.create(user: current_user, room: @room)
    @participation_id = participation.id
    @rating = Rating.new
  end

  def set_room
    @room = Room.where('token = ?', params['token']).first
  end
end
