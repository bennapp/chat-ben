class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room]}"
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, true)

    Participation.find_or_create_by(user: current_user, room: room).update_attribute(:deleted_at, nil)
  end

  def unsubscribed
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, false)

    Participation.find_by(user: current_user, room: room).destroy
  end

  def next_post(data)
    advance_post(data)
  end

  def prev_post(data)
    advance_post(data, prev_post: true)
  end

  private

  def advance_post(data, options = {})
    room = Room.find_by_token(params[:room])
    bin = Bin.find(data['bin_id'])
    current_post_id = data['post_id'].to_i

    posts = bin.posts.to_a
    posts = posts.reverse if options[:prev_post] == true

    current_post = Post.find(current_post_id)
    current_post_index = posts.index(current_post)

    if current_post_index
      next_post_index = current_post_index + 1
      post = posts[next_post_index % posts.size]
    else
      post = posts.first
    end

    options = generate_post_options(post)
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def generate_post_options(post)
    like = Like.where(user_id: current_user.id, post_id: post.id).first
    if like.present?
      dislike_exists = like.dislike?
      like_exists = !dislike_exists
    end

    like_count = post.like_count

    reaction_urls = post.reactions.map { |reaction| reaction.video.url }

    {
      action: 'advance_post',
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
      comment: post.comment,
      edited_by: post.last_editor.try(:name),
      reaction_urls: reaction_urls
    }
  end
end