class PostBin < ActiveRecord::Base
  belongs_to :post
  belongs_to :bin, autosave: true

  after_save :announce_position_one

  def announce_position_one
    if position == 0
      ActionCable.server.broadcast("bin_#{bin_id}", { post_id: post_id, action: 'new_top_post' })
    end
  end
end
