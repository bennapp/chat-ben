class LikeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "like_channel"

    current_user.update_attribute(:active, true) if current_user.present?
    ActionCable.server.broadcast "like_channel", action: 'total_users', value: User.where(active: true).count
  end

  def unsubscribed
    current_user.update_attribute(:active, false) if current_user.present?
    ActionCable.server.broadcast "like_channel", action: 'total_users', value: User.where(active: true).count
  end
end