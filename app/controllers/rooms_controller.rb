class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :update]

  def update
    @room.update_attribute(:waiting, false) # all you can update is that you are no long waiting when you leave
    render nothing: true
  end

  def show
    @bins = Bin.all
    @post = Post.new
    @hide_footer = true

    redirect_to root_url and return unless @room

    GuidePosition.find_or_create_by(user: current_user, bin: @room.bin)
    @participation_id = Participation.find_or_create_by(user: current_user, room: @room).id
    @rating = Rating.new
  end

  def set_room
    @room = Room.where('token = ?', params['token']).first
  end
end
