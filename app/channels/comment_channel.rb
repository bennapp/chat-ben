class CommentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comment_channel"
  end

  def unsubscribed
    puts 'unsubscribed'
  end

  def comment(data)
    return unless current_user
    post = Post.find(data['post_id'])
    post.last_editor = current_user
    post.comment = data['comment']
    post.save!

    ActionCable.server.broadcast "comment_channel", action: 'new_comment', post_id: post.id, comment: post.comment, edited_by: current_user.name
  end
end