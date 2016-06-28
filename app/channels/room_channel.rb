class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room]}"
    room = Room.find_by_token(params[:room])

    unless params[:mobile]
      room.update_attribute(:waiting, true)
      room.update_attribute(:participant_count, room.participant_count + 1)
      Participation.find_or_create_by(user: current_user, room: room).update_attribute(:deleted_at, nil) if current_user
    end
  end

  def unsubscribed
    room = Room.find_by_token(params[:room])

    unless params[:mobile]
      room.update_attribute(:waiting, false)
      room.update_attribute(:participant_count, room.participant_count - 1)
      Participation.find_by(user: current_user, room: room).destroy if current_user
    end
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
    room.update_attribute(:waiting, matching)

    current_user.update_attribute(:matching, matching) if current_user
  end

  private

  def advance_post(data, options = {})
    room = Room.find_by_token(params[:room])
    bin = Bin.find(data['bin_id'])
    current_post = Post.find(data['post_id'].to_i)

    posts = bin.posts.order('post_bins.position asc').to_a
    posts = posts.reverse if options[:prev_post] == true

    current_post_index = posts.index(current_post)

    if current_post_index
      if data['guide']
        next_post_index = current_post_index
      else
        next_post_index = current_post_index + 1
      end

      post = posts[next_post_index % posts.size]
    else
      post = posts.first
    end

    options = generate_post_options(post, room, bin, data['from_token'])
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def advance_channel(data, options = {})
    room = Room.find_by_token(params[:room])
    current_bin = Bin.find(data['bin_id'])
    bins = Bin.without_deleted.includes(:posts).order('post_bins.position asc').order(:position).to_a

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

    posts = bin.posts.to_a
    post = posts.first

    options = generate_post_options(post, room, bin, data['from_token'])
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def generate_post_options(post, room, bin, from_token)
    if current_user
      like = Like.where(user_id: current_user.id, post_id: post.id).first
    end

    if like.present?
      dislike_exists = like.dislike?
      like_exists = !dislike_exists
    end

    like_count = post.like_count

    reaction_urls = post.reactions.map { |reaction| reaction.video.url }

    room.update_attribute(:bin, bin)
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
      comment: post.comment,
      edited_by: post.last_editor.try(:name),
      reaction_urls: reaction_urls,
      bin_title: bin.title,
      bin_id: bin.id,
      bin_number: bin.position + 1,
      bin_logo_src: bin.logo(:medium),
      bin_description: bin.description,
      bin_abbreviation: bin.abbreviation,
      from_token: from_token,
    }
  end
end