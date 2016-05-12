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

    if data['post_history'].present?
      post_history = data['post_history'].map(&:to_i)
    else
      post_history = []
    end

    if data['bin_id'].present?
      current_post_id = data['post_id'].to_i
      posts = Bin.find(data['bin_id']).posts
      post = posts.select { |post| !post_history.include?(post.id) && post.id != current_post_id }.first
    elsif data['first_post']
      post = Post.find(data['post_id'].to_i)
    else
      posts = Post.without_deleted.from_three_weeks_ago
      posts = posts.sort_by { |post| post.sort_order }
      posts = posts.reject { |post| post.like_count <= -3 }

      current_post_id = data['post_id'].to_i

      if rand(1) == 1
        post = posts.select { |post| !post_history.include?(post.id) && post.id != current_post_id }.first
      else
        post = posts.select { |post| !post_history.include?(post.id) && post.id != current_post_id }.sample()
      end

      post = posts[0] if post.nil?
    end

    like = Like.where(user_id: current_user.id, post_id: post.id).first
    if like.present?
      dislike_exists = like.dislike?
      like_exists = !dislike_exists
    end

    like_count = post.like_count

    reaction_urls = post.reactions.map { |reaction| reaction.video.url }

    options = {
      action: 'next_post',
      id: post.id,
      title: post.title,
      link: post.link,
      format_link: post.format_link,
      format_type: post.format_type,
      text_content: post.text_content,
      like: like_exists,
      dislike: dislike_exists,
      like_count: like_count,
      full_url: post.full_url,
      link: post.link,
      first_post: data['first_post'],
      comment: post.comment,
      edited_by: post.last_editor.try(:name),
      reaction_urls: reaction_urls
    }

    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def add_reaction(data)
    post = Post.find(data['post_id'])
    reaction_url = post.reactions.first.video.url
    options = {
      action: 'add_reaction',
      reaction_url: reaction_url
    }

    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end
end