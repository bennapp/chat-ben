class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room]}"
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, true)

    Participation.find_or_create_by(user: current_user, room: room).update_attribute(:deleted_at, nil)
    ActionCable.server.broadcast "post_channel", action: 'num_waiting', post_id: room.post_id, num_waiting: room.post.num_waiting
  end

  def unsubscribed
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, false)

    Participation.find_by(user: current_user, room: room).destroy
    ActionCable.server.broadcast "post_channel", action: 'num_waiting', post_id: room.post_id, num_waiting: room.post.num_waiting
  end

  def next_post(data)
    room = Room.find_by_token(params[:room])
    # Remove this rooms post from the list of next
    posts = Post.without_deleted.from_three_weeks_ago
    posts = posts.sort_by { |post| post.sticky? ? -2**16 : -post.likes.count }
    current_post_id = data['post_id'].to_i
    current_post_index = posts.find_index { |post| post.id == current_post_id }
    next_post = posts[current_post_index + 1]
    next_post = posts[0] if next_post.nil?

    like_exists = Like.where(user_id: current_user.id, post_id: next_post.id).exists?
    like_count = Like.where(post_id: next_post.id).count
    posted_by = next_post.user.name

    ActionCable.server.broadcast "room_#{params[:room]}", action: 'next_post', id: next_post.id, title: next_post.title, link: next_post.link, format_link: next_post.format_link, format_type: next_post.format_type, text_content: next_post.text_content, like: like_exists, posted_by: posted_by, like_count: like_count
  end

  def like(data)
    current_post_id = data['post_id'].to_i
    Like.find_or_create_by(user: current_user, post_id: current_post_id)
  end

  def unlike(data)
    current_post_id = data['post_id'].to_i
    like = Like.where(user: current_user, post_id: current_post_id).first
    like.destroy if like.present?
  end
end