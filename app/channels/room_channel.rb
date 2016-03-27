class RoomChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, true)
    Participation.find_or_create_by(user: current_user, room: room)
  end

  def unsubscribed
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, false)
    Participation.find_by(user: current_user, room: room).destroy
  end
end