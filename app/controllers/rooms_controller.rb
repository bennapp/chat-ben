class RoomsController < ApplicationController
  before_action :set_room, only: [:show]

  def show
    participation = Participation.find_or_create_by(user: current_user, room: @room)
    @subtitle = @room.post.title
    @participation_id = participation.id
    @rating = Rating.new
  end

  def set_room
    @room = Room.where('token = ?', params['token']).first
  end
end
