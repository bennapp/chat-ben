class Participation < ActiveRecord::Base
  # acts_as_paranoid
  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :with_deleted, -> { where.not(deleted_at: nil) }
  # end acts_as_paranoid

  belongs_to :room
  belongs_to :user

  after_commit :update_room_and_num_waiting

  def update_room_and_num_waiting
    room.update_attribute(:full, room.participations.count >= 2)
    ActionCable.server.broadcast "posts_notfications_channel", action: 'num_waiting', post_id: room.post_id, num_waiting: room.post.num_waiting
  end

  validates :room, presence: true
  validates :user, presence: true
end
