class PostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "posts_notfications_channel"
  end

  def unsubscribed
    puts 'unsubscribed'
  end

  # def appear(data)
  #   puts 'appear'
  #   data['appearing_on']
  #   # post = Post.new
  #   # post.title = 'this was made from a websocket code path'
  #   # post.user = current_user
  #   # post.save!
  # end
end