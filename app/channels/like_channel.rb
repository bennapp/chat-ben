class LikeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "like_channel"
    stream_from "like_channel_#{current_user.id}" if current_user.present?

    current_user.update_attribute(:active, true) if current_user.present?
    ActionCable.server.broadcast "like_channel", action: 'total_users', value: User.where(active: true).count
  end

  def unsubscribed
    current_user.update_attribute(:active, false) if current_user.present?
    ActionCable.server.broadcast "like_channel", action: 'total_users', value: User.where(active: true).count
  end

  def like(data)
    current_post_id = data['post_id'].to_i

    like = Like.find_or_create_by(user: current_user, post_id: current_post_id)
    like.update_attribute(:dislike, false)

    post = Post.find(current_post_id)
    ActionCable.server.broadcast "like_channel", action: 'like_count', post_id: current_post_id, like_count: post.like_count
    ActionCable.server.broadcast "like_channel_#{post.user.id}", action: 'like', like: true unless post.user.id == current_user.id
  end

  def unlike(data)
    current_post_id = data['post_id'].to_i

    like = Like.where(user: current_user, post_id: current_post_id, dislike: false).first
    like.destroy if like.present?

    post = Post.find(current_post_id)
    ActionCable.server.broadcast "like_channel", action: 'like_count', post_id: current_post_id, like_count: post.like_count
    ActionCable.server.broadcast "like_channel_#{post.user.id}", action: 'like', like: false unless post.user.id == current_user.id
  end

  def dislike(data)
    current_post_id = data['post_id'].to_i

    like = Like.find_or_create_by(user: current_user, post_id: current_post_id)
    like.update_attribute(:dislike, true)

    post = Post.find(current_post_id)
    ActionCable.server.broadcast "like_channel", action: 'like_count', post_id: current_post_id, like_count: post.like_count
    ActionCable.server.broadcast "like_channel_#{post.user.id}", action: 'like', like: false unless post.user.id == current_user.id
  end

  def undislike(data)
    current_post_id = data['post_id'].to_i

    like = Like.where(user: current_user, post_id: current_post_id, dislike: true).first
    like.destroy if like.present?

    post = Post.find(current_post_id)
    ActionCable.server.broadcast "like_channel", action: 'like_count', post_id: current_post_id, like_count: post.like_count
    ActionCable.server.broadcast "like_channel_#{post.user.id}", action: 'like', like: true unless post.user.id == current_user.id
  end
end