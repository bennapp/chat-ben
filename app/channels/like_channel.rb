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

  def like(data)
    current_post_id = data['post_id'].to_i
    Like.find_or_create_by(user: current_user, post_id: current_post_id)

    ActionCable.server.broadcast "like_channel", action: 'like_count', post_id: current_post_id, like_count: Post.find(current_post_id).likes.count
  end

  def unlike(data)
    current_post_id = data['post_id'].to_i
    like = Like.where(user: current_user, post_id: current_post_id).first
    like.destroy if like.present?

    ActionCable.server.broadcast "like_channel", action: 'like_count', post_id: current_post_id, like_count: Post.find(current_post_id).likes.count
  end
end