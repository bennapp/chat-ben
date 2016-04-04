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
    current_post_id = data['post_id'].to_i
    current_post_index = posts.find_index { |post| post.id == current_post_id }
    next_post = posts[current_post_index + 1]
    next_post = posts[0] if next_post.nil?

    ActionCable.server.broadcast "room_#{params[:room]}", action: 'next_post', id: next_post.id, title: next_post.title, link: next_post.link, format_link: next_post.format_link, format_type: next_post.format_type, text_content: next_post.text_content
  end
end