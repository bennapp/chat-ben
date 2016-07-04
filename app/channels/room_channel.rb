class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room]}"
    room = Room.find_by_token(params[:room])

    unless params[:mobile]
      room.update_attribute(:waiting, true) if !current_user || (current_user && current_user.matching?)
      room.update_attribute(:participant_count, room.participant_count + 1)
      Participation.find_or_create_by(user: current_user, room: room).update_attribute(:deleted_at, nil) if current_user
    end
  end

  def unsubscribed
    room = Room.find_by_token(params[:room])

    unless params[:mobile]
      @offset ||= {}
      @offset[params[:room]] ||= 0

      if @offset[params[:room]] > 0
        @offset[params[:room]] -= 1
      else
        room.update_attribute(:participant_count, room.participant_count - 1)
      end

      room.update_attribute(:waiting, false) if room.participant_count == 0
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
    solo = data['solo']
    room = Room.find_by_token(params[:room])
    room.update_attribute(:waiting, !!matching)

    current_user.update_attribute(:matching, !!matching) if current_user
    current_user.update_attribute(:solo, !!solo) if current_user
  end

  def end_conversation(data)
    room = Room.find_by_token(params[:room])

    @offset ||= {}
    @offset[params[:room]] ||= 0
    @offset[params[:room]] += 1

    room.update_attribute(:participant_count, room.participant_count - 1)
    participation = Participation.find_by(user: current_user, room: room)
    participation.destroy if current_user && participation
  end

  def add_show(data)
    return unless current_user.present?
    link = data['value']
    post = Post.new(link: link, title: link)

    post.format_link_into_lightbox_html
    return unless post.format_type.present?
    post.user = current_user

    bin = Bin.find_or_create_by(user: current_user)
    bin.update_attribute(:title, "#{current_user.name}'s Channel") if bin.title.nil?
    name = current_user.name
    bin.update_attribute(:abbreviation, name.size < 9 ? name.upcase : name.gsub(/[aeiou]/i, '').upcase) if bin.abbreviation.nil?

    post.save!
    bin.post_bins.each_with_index do |post_bin, index|
      post_bin.update_attribute(:position, index + 1)
    end
    PostBin.create(post_id: post.id, bin_id: bin.id, position: 0)

    advance_post(data.merge("guide" => true, "post_id" => post.id.to_s, "bin_id" => bin.id.to_s, "new_post" => true))
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

      post = posts[next_post_index]
    end

    if post.nil?
      if options[:prev_post] == true
        bin = Bin.where(position: bin.position - 1).first
        bin = Bin.first if bin.nil?
        post = bin.posts.order('post_bins.position asc').last
      else
        bin = Bin.where(position: bin.position + 1).first
        bin = Bin.first if bin.nil?
        post = bin.posts.order('post_bins.position asc').limit(1).first
      end
    end

    options = generate_post_options(post, room, bin, data)
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def advance_channel(data, options = {})
    room = Room.find_by_token(params[:room])
    current_bin = Bin.find(data['bin_id'])
    current_bin_index = current_bin.position

    if current_bin_index
      if options[:down] == true
        next_bin_index = current_bin_index + 1
      else
        next_bin_index = current_bin_index - 1
      end

      bin = Bin.without_deleted.where(position: next_bin_index).first
    end

    bin = Bin.without_deleted.first if bin.nil?

    post = bin.posts.order('post_bins.position asc').limit(1).first
    options = generate_post_options(post, room, bin, data)
    ActionCable.server.broadcast("room_#{params[:room]}", options)
  end

  def generate_post_options(post, room, bin, data)
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
      from_token: data['from_token'],
      new_post: data['new_post'],
    }
  end
end