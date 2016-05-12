class CommentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comment_channel"
  end

  def unsubscribed
    puts 'unsubscribed'
  end

  def add_reaction(data)
    post = Post.find(data['post_id'])
    reaction_url = post.reactions.first.video.url
    options = {
      action: 'add_reaction',
      reaction_url: reaction_url,
      post_id: post.id,
    }

    ActionCable.server.broadcast("comment_channel", options)
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