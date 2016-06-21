class Participation < ActiveRecord::Base
  belongs_to :room
  belongs_to :user

  after_commit :update_room_full

  def update_room_full
    room.update_attribute(:full, room.participations.count >= 2)
  end

  validates :room, presence: true
  validates :user, presence: true
end
