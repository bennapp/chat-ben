class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :update]

  def update
    @room.touch
    render nothing: true
  end

  def show
    @hide_footer = true
    redirect_to root_url and return unless @room
    participation = Participation.find_or_create_by(user: current_user, room: @room)
    @subtitle = @room.post.title
    @participation_id = participation.id
    @rating = Rating.new
  end

  def set_room
    @room = Room.with_deleted.where('token = ?', params['token']).first
  end
end
