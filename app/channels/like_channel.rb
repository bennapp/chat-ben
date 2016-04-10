class LikeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "like_channel"

    total_users = Stat.find_or_create_by(title: 'total_users')
    total_users.value = total_users.value.to_i + 1
    total_users.save

    ActionCable.server.broadcast "like_channel", action: 'total_users', value: total_users.value
  end

  def unsubscribed
    puts 'unsubscribed'

    total_users = Stat.find_or_create_by(title: 'total_users')
    total_users.value = total_users.value.to_i - 1
    total_users.save

    ActionCable.server.broadcast "like_channel", action: 'total_users', value: total_users.value
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