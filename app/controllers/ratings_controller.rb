class RatingsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:banned]
  skip_before_filter :redirect_if_banned, only: [:banned]
  after_action :sign_out_banned_user, only: [:banned]

  def create
    @rating = Rating.new(rating_params)
    @rating.rater = current_user
    room = Room.where(id: @rating.room_id).first
    p room
    parts = room.participations
    p parts
    @rating.ratee_id = Room.where(id: @rating.room_id).first.participations.where('user_id != ?', current_user.id).pluck(:user_id).last

    @rating.save!
    render nothing: true
  end

  def rating_params
    params.require(:rating).permit(:value, :nsfw, :room_id)
  end

  def sign_out_banned_user
    sign_out current_user if current_user && current_user.banned?
  end
end
