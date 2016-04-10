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

    if data['first_post']
      post = Post.find(data['post_id'].to_i)
    else
      posts = Post.without_deleted.from_three_weeks_ago
      posts = posts.sort_by { |post| post.sort_order }
      posts = posts.reject { |post| post.like_count <= -3 }

      current_post_id = data['post_id'].to_i
      current_post_index = posts.find_index { |post| post.id == current_post_id }
      post = posts[current_post_index + 1]
      post = posts[0] if post.nil?
    end

    like = Like.where(user_id: current_user.id, post_id: post.id).first
    if like.present?
      dislike_exists = like.dislike?
      like_exists = !dislike_exists
    end

    like_count = post.like_count
    posted_by = post.user.name

    ActionCable.server.broadcast "room_#{params[:room]}", action: 'next_post', id: post.id, title: post.title, link: post.link, format_link: post.format_link, format_type: post.format_type, text_content: post.text_content, like: like_exists, dislike: dislike_exists, posted_by: posted_by, like_count: like_count, full_url: post.full_url, link: post.link, first_post: data['first_post']
  end
end