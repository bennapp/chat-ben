class PostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "posts_notfications_channel"
  end

  def unsubscribed
    puts 'unsubscribed'
  end
end