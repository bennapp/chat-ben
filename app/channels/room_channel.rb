class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room]}"
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, true) if current_user && current_user.matching?

    Participation.find_or_create_by(user: current_user, room: room).update_attribute(:deleted_at, nil) if current_user
  end

  def unsubscribed
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, false)

    Participation.find_by(user: current_user, room: room).destroy if current_user
  end

  def next_post(data)
    advance_post(data)
  end

  def prev_post(data)
    advance_post(data, prev_post: true)
  end

  def channel_up(data)
    advance_channel(data)
  end

  def channel_down(data)
    advance_channel(data, down: true)
  end

  def set_matching(data)
    matching = data['matching']
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, true) if matching

    current_user.update_attribute(:matching, matching) if current_user
  end

  private

  def advance_post(data, options = {})
    room = Room.find_by_token(params[:room])
    bin = Bin.find(data['bin_id'])
    current_post = Post.find(data['post_id'].to_i)

    posts = bin.posts.to_a
    posts = posts.reverse if options[:prev_post] == true
    current_post_index = posts.index(current_post)

    if current_post_index
      if data['guide']
        next_post_index = current_post_index
      else
        next_post_index = current_post_index + 1
      end

      guide_position = GuidePosition.find_or_create_by(user: current_user, bin: bin) if current_user
      guide_position.update_attribute(:position, next_post_index) if current_user

      post = posts[next_post_index % posts.size]
    else
      post = posts.first
    end

    options = generate_post_options(post, room, bin)
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def advance_channel(data, options = {})
    room = Room.find_by_token(params[:room])
    current_bin = Bin.find(data['bin_id'])
    bins = Bin.all.sort_by { |bin| bin.position }.to_a

    current_bin_index = bins.index(current_bin)

    if current_bin_index
      if options[:down] == true
        next_bin_index = current_bin_index + 1
      else
        next_bin_index = current_bin_index - 1
      end
      bin = bins[next_bin_index % bins.size]
    else
      bin = bin.first
    end

    room.update_attribute(:bin, bin)
    posts = bin.posts.to_a

    if current_user
      guide_position = GuidePosition.find_or_create_by(user: current_user, bin: bin)
      post = posts[guide_position.position]
    end

    post = posts.first if post.nil?

    options = generate_post_options(post, room, bin)
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def generate_post_options(post, room, bin)
    if current_user
      like = Like.where(user_id: current_user.id, post_id: post.id).first
    end

    if like.present?
      dislike_exists = like.dislike?
      like_exists = !dislike_exists
    end

    like_count = post.like_count

    reaction_urls = post.reactions.map { |reaction| reaction.video.url }

    room.update_attribute(:post, post)

    {
      action: 'advance_post',
      id: post.id,
      title: post.title,
      link: post.link,
      format_link: post.format_link,
      format_type: post.format_type,
      start_time: post.start_time,
      duration: post.duration,
      text_content: post.text_content,
      like: like_exists,
      dislike: dislike_exists,
      like_count: like_count,
      full_url: post.full_url,
      link: post.link,
      comment: post.comment,
      edited_by: post.last_editor.try(:name),
      reaction_urls: reaction_urls,
      bin_title: bin.title,
      bin_id: bin.id,
      bin_number: bin.position + 1,
      bin_logo_src: bin.logo(:thumb),
      bin_description: bin.description,
      user_name: current_user.try(:name),
    }
  end
end